# tagman.vim

Yet another Vim plugin for automatically generating [ctags](http://ctags.sourceforge.net/) files for your projects when files are saved and setting `tags` accordingly.

By default vendor or library code such as gem files and node modules are
ignored when generating project tag files.

Tagman also ignores all files listed in source control ignore files such as
`.gitignore`.

Library tag files can be generated separately and enabled or disabled as
desired.

All ctags operations are executed in the background so as not to hold up the
UI.

Tag files are automatically kept in source control directories at the top of
projects.

Tagman will only build tag files if a tag file already exists. You can enable
tags for a project by running `:BuildTags!`.

Tagman borrows heavily from https://github.com/szw/vim-tags.

Run `:help tagman` for more information and configuration options.
