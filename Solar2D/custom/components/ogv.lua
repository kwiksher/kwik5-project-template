-- custom.components.ogv — a Kwik class that plays an Ogg Theora clip as a display
-- object, through plugin.movie (CoronaExternalTexture), with a still-image
-- fallback when the clip or the native plugin is missing.
--
-- Attach it to a layer like any other class:
--
--   layers = { { cover_video = { class = { "ogv" } } } }
--
-- The per-layer instance file supplies the properties (book, video, still, ...).
-- See Solar2D/App/<book>-video/components/<page>/layers/<page>_video_ogv.lua.
--
-- Two things learned the hard way on this plugin:
--
--   * plugin.movie wants a *resource-relative* filename. Hand it an absolute path
--     (what system.pathForFile returns) and it fails with
--     "attempt to index a nil value", because it calls pathForFile() again
--     internally and gets nil back.
--   * MovieRect is built from texture.filename. In a Kwik layer that produced an
--     object with a nil .texture and no parent, so nothing ever decoded. This
--     class therefore uses the plugin's documented DIY path: create the
--     MovieTexture, create the ImageRect from the path we resolved ourselves, and
--     hand the rect the texture.

local M = {}

local okMovie, movie = pcall(require, "plugin.movie")

local BUFFER_MS = 500   -- plugin.movie buffers; its README asks for ~0.5 s

local defaults = {
    book = nil,          -- book folder under App/ (Simulator/editor layout)
    video = nil,         -- book-relative: "assets/videos/cover.ogv"
    still = nil,         -- poster / fallback
    autoplay = true,
    loop = false,
    channel = 3,
    volume = 1,
    playDelay = BUFFER_MS,
    keepStillVisible = false,
    narration = nil,
    chromaEffect = nil,  -- "custom.chromaKey": the effect this class defines
    chromaColor = "#00B140",
    chromaTolerance = 0.42,
    controls = true,     -- transport bar: restart / play-pause / stop / rewind
    fps = 16,            -- clip frame rate; paces the decoder's update()
    aspect = nil,        -- w/h of the clip's box; nil = the page's 16:9
    stackSync = false,   -- this bar drives every layer on the page
    controlsOffset = 0,  -- nudge the bar down, to keep stacked bars apart
    compactControls = false, -- plate hugs the buttons instead of the whole layer
    capture = nil,       -- debug: display.save() this filename into Documents
    debug = false,       -- writes /tmp/ogv.log
}


--- Runtime chroma key, as a custom effect.
--
-- Theora has no alpha, so a green-screen clip has to be keyed while it plays.
-- Solar2D's built-in "filter.chromaKey" applies with its own default uniforms and
-- keyed entire frames out (nothing could bind the key colour: uniforms are a
-- "forthcoming" feature, the built-in filter exposes no vertexData). This effect
-- takes the key colour and tolerance as four scalars through
-- CoronaVertexUserData, which is the supported way to pass parameters.
local CHROMA_EFFECT = "filter.custom.ogvChromaKey"
local chromaDefined = false

local CHROMA_KERNEL = {
    category = "filter",
    name = "ogvChromaKey",
    vertexData = {
        { name = "keyR",      default = 0.00, min = 0, max = 1, index = 0 },
        { name = "keyG",      default = 0.70, min = 0, max = 1, index = 1 },
        { name = "keyB",      default = 0.25, min = 0, max = 1, index = 2 },
        { name = "tolerance", default = 0.25, min = 0, max = 2, index = 3 },
    },
    fragment = [[
P_COLOR vec4 FragmentKernel( P_UV vec2 texCoord )
{
    P_COLOR vec4 texColor = texture2D( CoronaSampler0, texCoord );

    // Solar2D hands us premultiplied alpha; undo it to compare real RGB.
    P_DEFAULT float a = max( texColor.a, 0.0001 );
    P_DEFAULT vec3 rgb = texColor.rgb / a;

    P_DEFAULT vec3 key = vec3( CoronaVertexUserData.x, CoronaVertexUserData.y, CoronaVertexUserData.z );
    P_DEFAULT float tol = max( CoronaVertexUserData.w, 0.0001 );

    // soft edge instead of a hard cut, so hair and fur do not get a jagged rim
    P_DEFAULT float d = distance( rgb, key );
    P_DEFAULT float keep = smoothstep( tol * 0.35, tol, d );

    // Despill: clamp the key's dominant channel to the other two, which is what
    // removes the green rim from hair and fur. (Adding "spill" here instead made
    // the fringe worse — it has to be subtracted, never added.)
    if ( key.g >= key.r && key.g >= key.b ) {
        P_DEFAULT float maxRB = max( rgb.r, rgb.b );
        rgb.g = min( rgb.g, maxRB + 0.04 );
    } else if ( key.b >= key.r && key.b >= key.g ) {
        P_DEFAULT float maxRG = max( rgb.r, rgb.g );
        rgb.b = min( rgb.b, maxRG + 0.04 );
    } else {
        P_DEFAULT float maxGB = max( rgb.g, rgb.b );
        rgb.r = min( rgb.r, maxGB + 0.04 );
    }

    P_DEFAULT float outA = a * keep;
    return CoronaColorScale( vec4( rgb * outA, outA ) );
}
    ]],
}

local function defineChroma()
    if chromaDefined then return true end
    local ok, err = pcall(graphics.defineEffect, CHROMA_KERNEL)
    if not ok then
        print("[ogv] could not define the chroma effect: " .. tostring(err))
        return false
    end
    chromaDefined = true
    return true
end

local function hexToRgb(hex)
    local v = tostring(hex or ""):gsub("#", "")
    if #v ~= 6 then return 0, 0.70, 0.25 end
    return tonumber(v:sub(1, 2), 16) / 255,
           tonumber(v:sub(3, 4), 16) / 255,
           tonumber(v:sub(5, 6), 16) / 255
end

local function props(self)
    return self.properties or {}
end

--- Resolve a book-relative asset against the two layouts a Kwik app can have.
-- Built app: the resource root *is* the book, so the path resolves directly.
-- Simulator/editor: the resource root is the Solar2D project, so the file is at
-- App/<book>/<path>. Returns the resource-relative string, never the absolute
-- path (plugin.movie re-resolves it itself).
local function resolveAsset(path, book)
    if not path or path == "" then return nil end
    local candidates = { path }
    if book and book ~= "" then
        candidates[#candidates + 1] = "App/" .. book .. "/" .. path
    end
    for i = 1, #candidates do
        if system.pathForFile(candidates[i], system.ResourceDirectory) then
            return candidates[i]
        end
    end
    return nil
end


local function trace(self, ...)
    local p = props(self)
    if not p.debug then return end
    local t = {}
    for i = 1, select("#", ...) do t[#t + 1] = tostring(select(i, ...)) end
    local f = io.open("/tmp/ogv.log", "a")
    if f then f:write(table.concat(t, " ") .. "\n") f:close() end
end

--- The transport bar: restart (|◀), play/pause (▶/❚❚), stop (■), rewind (◀◀).
--
-- No playhead: the plugin's currentTime is wall-clock since playback started, not
-- the media position, so a progress bar would show a lie.
--
-- Built from shapes rather than glyphs: a system font is not guaranteed to carry
-- media symbols on every platform, and a triangle never renders as a tofu box.
local function buildControls(self, ref, w, h, group)
    local BTNS = 4          -- restart, play/pause, stop, visibility
    local btnW = math.max(26, math.round(w * 0.075))
    local gap = btnW * 0.35
    local total = btnW * BTNS + gap * (BTNS - 1)
    -- One row of four buttons has to fit the layer's own box. On a page take
    -- (480 wide) it always did; a split take is cropped to one character (~100
    -- wide), and there the row overflowed the plate, which drew the glyphs
    -- outside their own hit area: visible buttons that could not be tapped. It
    -- also overflowed the *layer*, so on a stacked page one layer's plate
    -- covered its neighbour's. Shrink the bar to fit the box; the plate is the
    -- touch target, so it must contain every glyph.
    local barH = btnW
    if total > w then
        -- 4 buttons + 3 gaps = 5.05 x button
        barH = math.max(16, math.floor((w / 5.05) * 10) / 10)
        btnW, gap = barH, barH * 0.35
        total = btnW * BTNS + gap * (BTNS - 1)
    end

    local bar = display.newGroup()
    -- every display object a page creates belongs to the page's sceneGroup; a
    -- parentless group lives on the stage and outlives the page turn
    if group then pcall(function() group:insert(bar) end) end
    bar.x, bar.y = ref.x, ref.y + h * 0.5 + barH * 0.75
    local off = tonumber(props(self).controlsOffset) or 0
    if off ~= 0 then bar.y = bar.y + off end

    -- A per-character bar must not span its whole layer: two full-width plates on
    -- one page sit on top of each other. `compactControls` hugs the buttons so
    -- each character's bar stays its own touch target.
    local plateW = w
    if props(self).compactControls then plateW = total + 10 end
    local plate = display.newRect(bar, 0, 0, plateW, barH)
    plate:setFillColor(0, 0, 0, 0.45)
    plate.isHitTestable = true

    local startX = -total * 0.5 + btnW * 0.5

    local slots = {}
    local function button(index, draw)
        local g = display.newGroup()
        bar:insert(g)
        g.x = startX + (btnW + gap) * (index - 1)
        -- visuals only: the touch target is the plate, see below
        local glyph = display.newGroup()
        g:insert(glyph)
        draw(glyph, btnW * 0.30)
        slots[index] = { x = g.x, half = (btnW + gap) * 0.5 }
        return g
    end

    -- restart (|◀)
    button(1, function(parent, r)
        -- |◀ : bar, then a left-pointing triangle
        local barA = display.newRect(parent, -r * 0.75, 0, r * 0.24, r * 1.8)
        barA:setFillColor(0.95, 0.93, 0.88)
        local tri = display.newPolygon(parent, r * 0.25, 0,
            { r, -r * 0.9, r, r * 0.9, -r * 0.6, 0 })
        tri:setFillColor(0.95, 0.93, 0.88)
    end)


    -- play / pause (▶ / ||) — one glyph visible at a time
    local glyphState = {}
    button(2, function(parent, r)
        local tri = display.newPolygon(parent, 0, 0,
            { -r * 0.8, -r, -r * 0.8, r, r * 1.0, 0 })
        tri:setFillColor(0.98, 0.85, 0.45)
        glyphState.play = tri
        local p1 = display.newRect(parent, -r * 0.42, 0, r * 0.5, r * 1.9)
        p1:setFillColor(0.98, 0.85, 0.45)
        local p2 = display.newRect(parent, r * 0.42, 0, r * 0.5, r * 1.9)
        p2:setFillColor(0.98, 0.85, 0.45)
        glyphState.pause = { p1, p2 }
    end)


    -- stop (■)
    button(3, function(parent, r)
        local sq = display.newRect(parent, 0, 0, r * 1.7, r * 1.7)
        sq:setFillColor(0.95, 0.93, 0.88)
    end)


    -- visibility (eye / eye with a slash): shows or hides this whole layer — clip
    -- and poster — so the character leaves the page rather than freezing.
    button(4, function(parent, r)
        local ring = display.newCircle(parent, 0, 0, r * 1.15)
        ring:setFillColor(0.95, 0.93, 0.88, 0.18)
        ring:setStrokeColor(0.95, 0.93, 0.88)
        ring.strokeWidth = math.max(1.2, r * 0.28)
        local dot = display.newCircle(parent, 0, 0, r * 0.42)
        dot:setFillColor(0.95, 0.93, 0.88)
        local slash = display.newRect(parent, 0, 0, r * 2.9, math.max(1.5, r * 0.26))
        slash.rotation = -45
        slash:setFillColor(0.95, 0.93, 0.88)
        slash.isVisible = false
        glyphState.eyeSlash = slash
    end)

    plate.isHitTestable = true
    plate:addEventListener("tap", function(event)
        local lx = plate:contentToLocal(event.x, event.y)
        for index, slot in pairs(slots) do
            if math.abs(lx - slot.x) <= slot.half then
                trace(self, "tap -> button ", index)
                -- 1 restart (rewind + play) · 2 play/pause · 3 stop (rewind,
                -- stay paused) · 4 visibility. There used to be a fifth button
                -- with the rewind glyph that ran the same action as button 1.
                if index == 1 then
                    self:restart()
                elseif index == 2 then
                    self:toggle()
                elseif index == 3 then
                    self:stop()
                elseif index == 4 then
                    self:toggleVisibility()
                end
                return true
            end
        end
        return false
    end)

    self._controls = {
        group = bar,
        plate = plate,
        glyphs = glyphState,
        hitToggle = plate,
        slots = slots,
    }

    -- the initial glyph has to match reality: with autoplay off nothing is playing
    self:_setPlaying(props(self).autoplay ~= false)
    self:_setVisibleGlyph(self._visible ~= false)
    return bar
end

local function posterObject(self, UI)
    local p = props(self)
    local name = p.name or self.name
    local obj = UI and UI.sceneGroup and UI.sceneGroup[name]
    if obj then return obj, name end
    local stillPath = resolveAsset(p.still, p.book)
    if not stillPath then return nil, name end
    local ok, img = pcall(display.newImageRect, UI.sceneGroup, stillPath,
                          p.width or 1280, p.height or 720)
    if not ok or not img then return nil, name end
    img.x = p.x or display.contentCenterX
    img.y = p.y or display.contentCenterY
    img.name = name
    return img, name
end

local function cancelTimer(self)
    if self._playTimer then
        timer.cancel(self._playTimer)
        self._playTimer = nil
    end
end

local function stopNarration(self)
    if self.narrationHandle then
        pcall(audio.stop, self.channel or 3)
        pcall(audio.dispose, self.narrationHandle)
        self.narrationHandle = nil
        trace(self, "narration stopped")
    end
end

-- One transport per page, driving every layer on it.
--
-- A stacked page (one clip per character) builds the transport bar only on its
-- first layer, so that bar used to control just that one character: pressing
-- pause stopped one character while the others kept playing. Instances now
-- register themselves by page in didShow, and every transport call is applied to
-- the whole stack.
local stacks = {}   -- page key -> { instances }

local function stackFor(self, UI)
    local page = (UI and (UI.page or UI.name)) or self._pageKey
    if page == nil then page = "?" end
    self._pageKey = page
    local list = stacks[page]
    if not list then list = {} stacks[page] = list end
    for i = 1, #list do if list[i] == self then return list end end
    list[#list + 1] = self
    return list
end

function M.set(target)
    target.class = target.class or "ogv"

    local given = target.properties
    target.properties = {}
    for k, v in pairs(defaults) do target.properties[k] = v end
    for k, v in pairs(given or {}) do target.properties[k] = v end

    function target:init(UI)
        self._isVideo = false
        trace(self, "init")
    end

    function target:create(UI)
        local p = props(self)
        -- the page's own group: every object this class builds goes in here, so a
        -- page turn takes them with it even if destroy() never runs
        self._sceneGroup = UI and UI.sceneGroup or nil
        local poster, name = posterObject(self, UI)
        self.poster = poster
        self.layerName = name
        trace(self, "create: name=", name, "video=", p.video, "book=", p.book,
                 "poster=", poster ~= nil, "plugin=", okMovie)

        local videoPath = resolveAsset(p.video, p.book)
        self._videoPath = videoPath
        if not okMovie or not videoPath then
            if not okMovie then
                print("[ogv] plugin.movie is not installed — '" .. tostring(name) ..
                      "' stays a still image")
            elseif p.video then
                print("[ogv] '" .. tostring(p.video) .. "' not found — keeping the still")
            end
            return
        end
        trace(self, "  videoPath=", videoPath)

        -- Without a poster object the layer's own geometry is the only source:
        -- x/y are offsets from the content centre and width/height are already in
        -- content units (a cropped layer's box), so both have to be applied here
        -- rather than used raw as page pixels.
        local ref = poster or {
            x = display.contentCenterX + (tonumber(p.x) or 0),
            y = display.contentCenterY + (tonumber(p.y) or 0),
            width = p.width or 1280, height = p.height or 720 }
        -- Geometry comes from the poster layer, which is already in content units
        -- (1920x1280 page frame x 0.25 = 480x320, Kwik's scale convention). The
        -- clip is 16:9 inside that 3:2 page.
        self._ref = ref
        self:_spawnVideo()

        if p.controls ~= false and self._size then
            buildControls(self, { x = ref.x, y = ref.y }, self._size[1], self._size[2],
                          self._sceneGroup)
        end

        if p.narration then
            local narrationPath = resolveAsset(p.narration, p.book)
            if narrationPath then
                self._narrationPath = narrationPath
                self:_startNarration()
            end
        end

        -- The plugin decodes from enterFrame ticks, but it does not pace itself:
        -- update() must be given the elapsed milliseconds since the last call, or
        -- the clock never moves (currentTime stayed 0 with a hardcoded 0).
        if self._update == nil then
            self._update = function(event)
                local m = self.movie
                if not (m and m.texture) then return end
                local now = (event and event.time) or system.getTimer()
                local delta = self._lastTime and (now - self._lastTime) or 16
                self._lastTime = now
                -- update() decodes one frame per call, so calling it every engine
                -- frame runs a 16 fps clip ~4x too fast (measured: 1.56 s of
                -- content inside 200 ms). Accumulate real time and step the
                -- decoder at the clip's own rate instead.
                local step = 1000 / ((props(self).fps) or 16)
                self._acc = (self._acc or 0) + delta
                local guard = 0
                while self._acc >= step and guard < 4 do
                    pcall(function() m.texture:update(step) end)
                    self._acc = self._acc - step
                    guard = guard + 1
                end
                pcall(function() m.texture:invalidate() end)
                -- keep the toggle glyph honest as the clip ends or restarts
                local st = nil
                pcall(function() st = m.texture.isPlaying end)
                if st ~= nil and st ~= self._shownPlaying then
                    self._shownPlaying = st
                    self:_setPlaying(st == true)
                end
            end
            Runtime:addEventListener("enterFrame", self._update)
        end

        if p.debug then
            timer.performWithDelay(1500, function()
                local m = self.movie
                if not m then trace(self, "  +1.5s: movie gone") return end
                local okct, ct = pcall(function() return m.texture and m.texture.currentTime end)
                local okfx, fx = pcall(function() return m.fill and m.fill.effect ~= nil end)
                if p.capture then
                    local okSave, errSave = pcall(display.save, display.getCurrentStage(),
                        { filename = p.capture, baseDir = system.DocumentsDirectory })
                    trace(self, "  capture ", p.capture, " ok=", okSave, " ", errSave)
                end
                local inPage = (self._sceneGroup ~= nil and m.parent == self._sceneGroup)
                trace(self, "  +1.5s inSceneGroup=", inPage,
                      " controlsInSceneGroup=",
                      (self._controls ~= nil and self._sceneGroup ~= nil
                       and self._controls.group.parent == self._sceneGroup))
                trace(self, "  +1.5s visible=", m.isVisible, " alpha=", m.alpha,
                      " w=", m.width, " h=", m.height,
                      " currentTime=", okct and ct or "ERR",
                      " effectSet=", okfx and fx or "ERR",
                      " posterVisible=", self.poster and self.poster.isVisible)
            end)
        end

        cancelTimer(self)
        if p.autoplay then
            self._playTimer = timer.performWithDelay(p.playDelay or BUFFER_MS, function()
                self._playTimer = nil
                self:play()
            end)
        end
    end


    --- Build (or rebuild) the MovieTexture + ImageRect for the current page.
    -- Called from create() and from restart(): the plugin cannot seek, so a rewind
    -- is a teardown and a rebuild.
    --- (Re)start the narration track. Called from create() and from didShow():
    -- a page turn stops the track, so the returning page has to speak again.
    function target:_startNarration()
        if not self._narrationPath then return end
        stopNarration(self)
        local okSnd, snd = pcall(audio.loadSound, self._narrationPath)
        if okSnd and snd then
            self.narrationHandle = snd
            pcall(audio.play, snd)
            trace(self, "narration started")
        else
            trace(self, "narration failed: ", tostring(self._narrationPath))
        end
    end

    function target:_spawnVideo()
        local p = props(self)
        local ref = self._ref or { x = display.contentCenterX, y = display.contentCenterY }
        local videoPath = self._videoPath
        trace(self, "  _spawnVideo path=", tostring(videoPath), " plugin=", tostring(okMovie))
        if not (okMovie and videoPath) then return end

        if self.movie then
            pcall(function() if self.movie.texture then self.movie.texture:stop() end end)
            pcall(function() if self.movie.texture then self.movie.texture:releaseSelf() end end)
            pcall(function() self.movie:removeSelf() end)
            self.movie = nil
        end

        local pageW = ref.width or p.width or 480
        local pageH = ref.height or p.height or 320
        -- The clip fills its box at the clip's own aspect. Every page take is
        -- 16:9, but a split take is encoded cropped to one character and is
        -- then taller than it is wide — forcing 16:9 on it would stretch the
        -- texture. `aspect` (w/h) is emitted by Scripts/video_stories.py from
        -- the shot's crop box; without it the page's 16:9 rule stands.
        local aspect = tonumber(p.aspect)
        if not aspect or aspect <= 0 then aspect = 16 / 9 end
        local w = pageW
        local h = w / aspect
        if h > pageH then
            h = pageH
            w = h * aspect
        end
        local rect

        -- Preferred: the plugin's own wrapper.
        local okWrap, wrapped = pcall(movie.newMovieRect, {
            x = ref.x, y = ref.y, width = w, height = h,
            channel = p.channel, filename = videoPath,
        })
        if okWrap and wrapped and wrapped.texture then
            rect = wrapped
        else
            trace(self, "newMovieRect unusable: ok=", okWrap, " texture=",
                  wrapped and tostring(wrapped.texture))
            -- DIY: the texture registers its own image with Corona, so the rect
            -- must be built from texture.filename/baseDir. Building it from the
            -- .ogv path instead yields "does not contain a valid image" and a
            -- blank rectangle that covers the whole page.
            local okTex, texture = pcall(movie.newMovieTexture, {
                filename = videoPath, channel = p.channel or 3,
            })
            if okTex and texture and texture.filename then
                -- parent it: an ImageRect created without a parent sits on the
                -- stage, outside the page, and survives the page turn
                local okRect, made
                if self._sceneGroup then
                    okRect, made = pcall(display.newImageRect, self._sceneGroup,
                                         texture.filename, texture.baseDir, w, h)
                else
                    okRect, made = pcall(display.newImageRect, texture.filename,
                                         texture.baseDir, w, h)
                end
                if okRect and made then
                    made.texture = texture
                    made.x, made.y = ref.x, ref.y
                    rect = made
                end
            else
                trace(self, "newMovieTexture unusable: ok=", okTex, " filename=",
                      texture and tostring(texture.filename))
            end
        end

        if rect == nil then
            print("[ogv] could not open '" .. tostring(videoPath) .. "' — keeping the still")
            return
        end

        -- the plugin's wrapper builds its own object; adopt it into the page group
        if self._sceneGroup and rect.parent ~= self._sceneGroup then
            pcall(function() self._sceneGroup:insert(rect) end)
        end
        rect.name = tostring(p.name or "video") .. "_movie"

        self.movie = rect
        self._isVideo = true
        if poster and not p.keepStillVisible then
            poster.isVisible = false
        end


        trace(self, "  _spawnVideo OK rect=", tostring(rect), " texture=", type(rect and rect.texture))
        self.movie = rect
        self._size = { w, h }
        self._isVideo = true
        if self.poster and not p.keepStillVisible then
            self.poster.isVisible = false
        end

        if p.chromaEffect then
            local r, g, b = hexToRgb(p.chromaColor)
            local okFx = true
            if p.chromaEffect == CHROMA_EFFECT or p.chromaEffect == "custom.chromaKey" then
                okFx = defineChroma()
            end
            if okFx then
                pcall(function()
                    rect.fill.effect = (p.chromaEffect == "custom.chromaKey") and CHROMA_EFFECT
                                        or p.chromaEffect
                    if p.chromaEffect == "custom.chromaKey" then
                        rect.fill.effect.keyR = r
                        rect.fill.effect.keyG = g
                        rect.fill.effect.keyB = b
                        rect.fill.effect.tolerance = p.chromaTolerance or 0.42
                    end
                end)
            end
        end

        if self._controls then
            pcall(function() self._controls.group:toFront() end)
        end
        self._lastTime = nil
        pcall(function() rect.texture:play() end)
        self._isVideo = true
    end

    --- Is there a usable texture? If not, try to open one exactly once.
    -- play() and restart() both rebuild from nothing, so each used to call the
    -- other; with no plugin or no file that recursed until the stack overflowed.
    function target:_ensureVideo()
        local m = self.movie
        if m and m.texture then return true end
        if self._opening then return false end
        self._opening = true
        self:_spawnVideo()
        self._opening = false
        m = self.movie
        return (m ~= nil and m.texture ~= nil)
    end

    --- Apply `fn` to every instance on this page (the transport is per page).
    function target:_eachOnPage(fn)
        -- per-layer bars stay independent: only a page transport (stackSync) fans
        -- out to its siblings, so pausing one character leaves the others running
        if not props(self).stackSync then return end
        local list = stacks[self._pageKey or "?"]
        if not list then fn(self) return end
        for i = 1, #list do
            local o = list[i]
            if o ~= self then pcall(fn, o) end
        end
    end

    --- Play just this layer (no stack fan-out). `autoplayGlyph` keeps the
    -- initial glyph in step with reality instead of forcing it to "playing".
    function target:_playSelf(autoplayGlyph)
        local m = self.movie
        if not m then
            if not self:_ensureVideo() then return end
            m = self.movie
        end
        if m.texture then
            pcall(function() m.texture:play() end)
            self._isVideo = true
            self:_setPlaying(not autoplayGlyph and true or props(self).autoplay ~= false)
        end
    end

    function target:play()
        self:_playSelf(false)
        self:_eachOnPage(function(o) o:_playSelf(false) end)
    end

    function target:_pauseSelf()
        local m = self.movie
        if m and m.texture then
            pcall(function() m.texture:pause() end)
            self:_setPlaying(false)
        end
    end

    function target:pause()
        self:_pauseSelf()
        self:_eachOnPage(function(o) o:_pauseSelf() end)
    end

    function target:toggle()
        local m = self.movie
        if not (m and m.texture) then
            -- stopped (or never started): the play button replays
            self:restart()
            return
        end
        local playing = m.texture.isPlaying
        if playing then self:pause() else self:play() end
        trace(self, "toggle -> playing=", tostring(not playing))
    end

    --- Tear the decoder down. After this there is no usable texture: the plugin
    --- frees it on stop(), and play() on the freed object crashes the runtime.
    function target:_teardownMovie()
        local m = self.movie
        if m then
            if m.texture then
                pcall(function() m.texture:stop() end)
            end
            pcall(function() m:removeSelf() end)
        end
        self.movie = nil
        self._isVideo = false
        self._lastTime = nil
    end

    --- Back to the first frame.
    --
    -- The plugin's stop() used to free the decoder, which made play() afterwards a
    -- use-after-free (it crashed the Simulator) and forced a teardown + rebuild
    -- from a second copy of the file. Fixed in plugin_movie: stop() now reopens the
    -- stream in place and keeps the texture usable, so this is just stop + play.
    function target:_restartSelf()
        if not self:_ensureVideo() then return end
        local m = self.movie
        pcall(function() m.texture:stop() end)
        self._lastTime = nil
        self._acc = 0
        pcall(function() m.texture:play() end)
        self._isVideo = true
        self:_setPlaying(true)
        trace(self, "restart")
    end

    function target:restart()
        self:_restartSelf()
        self:_eachOnPage(function(o) o:_restartSelf() end)
    end

    function target:_stopSelf()
        local m = self.movie
        if not (m and m.texture) then return end
        -- stop() rewinds to the first frame and leaves the texture usable
        pcall(function() m.texture:stop() end)
        self._lastTime = nil
        self._acc = 0
        self:_setPlaying(false)
        trace(self, "stop (rewound, texture kept)")
    end

    function target:stop()
        self:_stopSelf()
        self:_eachOnPage(function(o) o:_stopSelf() end)
    end

    function target:didShow(UI)
        trace(self, "didShow")
        local list = stackFor(self, UI)
        _G.__OGV_ALL = _G.__OGV_ALL or {}
        _G.__OGV_ALL[self.name] = self
        if self._isVideo then self:play() end
        if self._visible == false then self:setLayerVisible(false) end
        if self.narrationHandle == nil then self:_startNarration() end
    end

    function target:didHide(UI)
        trace(self, "didHide")
        cancelTimer(self)
        self:pause()
        -- the page is gone: its narration must not keep playing over the next one
        stopNarration(self)
        -- Do NOT tear the texture down here. Release/removeSelf on a live
        -- MovieTexture while the plugin's decode thread still holds it is a
        -- use-after-free: it segfaulted the Simulator on a page turn (measured).
        -- The objects this class builds are sceneGroup children, so the page turn
        -- takes them with the scene; destroying a texture is the plugin's job.
    end

    function target:destroy(UI)
        trace(self, "destroy")
        cancelTimer(self)
        if self._update then
            Runtime:removeEventListener("enterFrame", self._update)
            self._update = nil
        end
        self._lastTime = nil
        if self.movie then
            local m = self.movie
            pcall(function() if m.texture then m.texture:stop() end end)
            pcall(function() if m.texture then m.texture:releaseSelf() end end)
            pcall(function() m:removeSelf() end)
            self.movie = nil
        end
        stopNarration(self)
        if self._controls then
            pcall(function() self._controls.group:removeSelf() end)
            self._controls = nil
        end
        if self.poster then
            self.poster.isVisible = true
            self.poster = nil
        end
        self._isVideo = false
    end

    --- Reflect transport state on the toggle glyph. Defined for every instance,
    -- not just pages that build a transport bar: play/pause/stop and the debug
    -- trace all call it, and a cropped layer with `controls = false` never runs
    -- buildControls, so the method used to be nil and every play() errored.
    --- Reflect the eye glyph: a slash through it while the clip is hidden.
    function target:_setVisibleGlyph(visible)
        local g = self._controls and self._controls.glyphs
        if g and g.eyeSlash then g.eyeSlash.isVisible = not visible end
    end

    --- Show or hide this whole layer: the clip *and* its poster, so the character
    -- actually leaves the page — that is what "visibility" has to mean on a page
    -- stacking one character per layer. Playback state is untouched, so showing it
    -- again resumes where the stack was.
    function target:setLayerVisible(visible)
        self._visible = visible and true or false
        if self.movie then self.movie.isVisible = self._visible end
        if self.poster then
            -- with the layer visible the movie covers the poster; without a movie
            -- the poster is the layer, so it follows the same switch
            self.poster.isVisible = self._visible and not self._isVideo
        end
        self:_setVisibleGlyph(self._visible)
        trace(self, "layer visible=", tostring(self._visible))
    end

    function target:toggleVisibility()
        self:setLayerVisible(self._visible == false)
    end

    function target:_setPlaying(playing)
        local g = self._controls and self._controls.glyphs
        if not g then return end
        if g.play then g.play.isVisible = not playing end
        if g.pause then
            g.pause[1].isVisible = playing
            g.pause[2].isVisible = playing
        end
    end

    function target:isVideo()
        return self._isVideo == true
    end

    return target
end

return M
