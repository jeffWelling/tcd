In commit e507872b9f84accc69ff67e086f1eed54a58c3a2 I had to hardcode the path that loadPaths() globs in order to get it to work while daemonized.
