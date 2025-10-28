# Changelog

## [1.1.0](https://github.com/wsdjeg/zettelkasten.nvim/compare/v1.0.0...v1.1.0) (2025-10-28)


### Features

* add zettelkasten source for picker.nvim ([f7e4da4](https://github.com/wsdjeg/zettelkasten.nvim/commit/f7e4da4c593f5a34d72bb8ce92c2deb9cc93a145))
* add zettelkasten_tags source ([f9d4761](https://github.com/wsdjeg/zettelkasten.nvim/commit/f9d4761b224511ae5122159049ccff8129dbe398))
* support zk tags preview ([448fae3](https://github.com/wsdjeg/zettelkasten.nvim/commit/448fae3579fa91f7c9445ce852732aea31b791d2))
* use `<F2>` to toggle zettelkasten tag tree ([f7c7fe2](https://github.com/wsdjeg/zettelkasten.nvim/commit/f7c7fe2f02606b9a34f2344bea139602ce54a550))
* use api function instead of vim.cmd ([b85dcf4](https://github.com/wsdjeg/zettelkasten.nvim/commit/b85dcf413be3197a81fa5a33bf9c93a1ff2e1e36))


### Bug Fixes

* fix highlight range ([d44106b](https://github.com/wsdjeg/zettelkasten.nvim/commit/d44106b9942b70c14b82b2b73f5faf1ed76d766e))
* fix wrong key ([ae94168](https://github.com/wsdjeg/zettelkasten.nvim/commit/ae94168baf96871ff3010c1d9f5a11440062459d))
* fix zettelkasten browser ftdetect ([b7fcad9](https://github.com/wsdjeg/zettelkasten.nvim/commit/b7fcad9a8948ae10d109b1e88a5ecc6f5004327b))
* set buflisted to false on BufEnter ([7d75e96](https://github.com/wsdjeg/zettelkasten.nvim/commit/7d75e9632ff0d41671a1d94bb7a703f17505343e))

## 1.0.0 (2025-10-12)


### Features

* **easing:** use easing function in notify ([34a35b8](https://github.com/wsdjeg/zettelkasten.nvim/commit/34a35b8d1258aba7f490ea008c12f12b90463868))
* **nvim-plug:** add new plugin manager ([abc2d2c](https://github.com/wsdjeg/zettelkasten.nvim/commit/abc2d2cfe7cb246a36489475373ace98f0c2c669))
* **runtime:** add `--clear` to clear runtime log ([6864d89](https://github.com/wsdjeg/zettelkasten.nvim/commit/6864d89dd7814ee46b5a0a15d5e2cccec5bda6ce))
* **zettelkasten:** add zk tags tree ([05c1c09](https://github.com/wsdjeg/zettelkasten.nvim/commit/05c1c09492024a0ccee984d0b50f252d9b015022))
* **zettelkasten:** detach vim-zettelkasten plugin ([020a35a](https://github.com/wsdjeg/zettelkasten.nvim/commit/020a35ac80a81bd9e15da05efbb9a4c7cdce45cb))
* **zettelkasten:** filter zk tags ([08a851a](https://github.com/wsdjeg/zettelkasten.nvim/commit/08a851aa0db66e75938e4ffa55fe52183b08cb7c))
* **zettelkasten:** filter zk title via telescope ([c4e955f](https://github.com/wsdjeg/zettelkasten.nvim/commit/c4e955f01e3874874b95ed6edcbe52b0a9ad18b4))
* **zettelkasten:** sort tags in sidebar ([24c7930](https://github.com/wsdjeg/zettelkasten.nvim/commit/24c7930eaf8ca2f52fd6e6b3653f4c0f91d4a7e5))
* **zettelkasten:** use `<Enter>` to open note ([9be817c](https://github.com/wsdjeg/zettelkasten.nvim/commit/9be817cf6d0ee7d08638a853e8363f5e3a9d5d70))
* **zkbrowser:** use `<LeftRelease>` to filter tag ([1bc630c](https://github.com/wsdjeg/zettelkasten.nvim/commit/1bc630cd5ea2157351062b663c6e1ecc07c7a0ba))


### Bug Fixes

* **notify:** pcall viml notify ([f5c9a50](https://github.com/wsdjeg/zettelkasten.nvim/commit/f5c9a50e32a3d0d6b65e19a810eca16e87d70b17))
* **zettelkasten:** fix default telescope actions ([4b95222](https://github.com/wsdjeg/zettelkasten.nvim/commit/4b95222a2e245888810cb3e3657b98377f2afc1e))
* **zettelkasten:** fix title backgroup color ([877fe60](https://github.com/wsdjeg/zettelkasten.nvim/commit/877fe60c2406e3756765750361a22a0d0944edbb))
* **zettelkasten:** test zettelkasten plugin ([bcaeea4](https://github.com/wsdjeg/zettelkasten.nvim/commit/bcaeea4b63ca02dc1897f77c39b8f70d94a0e16f))
* **zettelkasten:** use string.sub for long title ([b803893](https://github.com/wsdjeg/zettelkasten.nvim/commit/b803893478eb6ac8cf7b9d0a9b5fc6331bc6b935))


### Performance Improvements

* **zettelkasten:** check title width ([d3c6b5f](https://github.com/wsdjeg/zettelkasten.nvim/commit/d3c6b5fd0d13284f5fa3a8a433c8c4256a73a54d))
