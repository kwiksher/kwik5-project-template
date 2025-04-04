## urlScheme

syntax: solar2d://open?url=file://<absolute-path-to-main.lua>&skin=<skin-name>

```
solar2d://open?url=file://C:/Users/ymmtny/Documents/GitHub/kwik5-project-template/Solar2D/main.lua
```

### Windows

- solar2d.reg will set the url schema with startSolar2D.bat
- startSolar2D.bat is installed with install_plugin.bat

### Mac

 urlShceme is supported in the original Solar2D Simulator


 ref: https://docs.coronalabs.com/tutorial/events/urlScheme/index.html

---
## Create Book

The create_book scripts are used to create new book projects with the specified structure.

### Windows (create_book.bat)

```bat
create_book.bat [destination] [book_name] [pages]
```

### macOS (create_book.command)

```bash
./create_book.command [destination] [book_name] [pages]
```

### Parameters

1. **destination**: The target directory where your project will be created (required)
2. **book_name**: The name of your book project (required)
3. **pages**: One or more page names separated by spaces (optional, defaults to "page1")

### Examples

Create a book named "MyStory" in the Solar2D directory with default page:

```
create_book.bat Solar2D MyStory
```

Or on macOS:

```
./create_book.command Solar2D MyStory
```

Create a book with multiple pages:

```
create_book.bat Solar2D MyStory "page1 page2 page3"
```

Or on macOS:

```
./create_book.command Solar2D MyStory "page1 page2 page3"
```

### Directory Structure

The script will create the following structure:

```
Solar2D/
└── App/
    └── MyStory/
        ├── assets/
        │   ├── images/
        │   │   └── page1/
        │   └── model.lua
        ├── commands/
        │   └── page1/
        ├── components/
        │   └── page1/
        │       ├── audios/
        │       ├── groups/
        │       ├── layers/
        │       ├── page/
        │       ├── timers/
        │       ├── variables/
        │       ├── joints/
        │       └── index.lua
        ├── models/
        │   └── page1/
        └── index.lua
```

### Notes

- On macOS, make sure the command script has execute permissions:
  ```bash
  chmod +x create_book.command
  ```
