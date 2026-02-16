# Changelog

## [2.2.0](https://github.com/wsdjeg/zettelkasten.nvim/compare/v2.1.0...v2.2.0) (2026-02-16)


### Features

* add browse_title_width option ([db176de](https://github.com/wsdjeg/zettelkasten.nvim/commit/db176de944dbfd64446aa55216ff31a871c8ce2b))
* add calendar.nvim extension ([a21a1df](https://github.com/wsdjeg/zettelkasten.nvim/commit/a21a1df959da683db104afcf6460bda36cc7cea8))
* add chat.nvim tool ([f3fdfd6](https://github.com/wsdjeg/zettelkasten.nvim/commit/f3fdfd6b914fce1401ff091d8682ef86d934829f))
* add zettelkasten_get tool ([9aa9038](https://github.com/wsdjeg/zettelkasten.nvim/commit/9aa90388c8ae1270759946b021a0bf2a344bc872))
* paste image from clipboard ([b294140](https://github.com/wsdjeg/zettelkasten.nvim/commit/b294140579bd20cadc184e753326ce339e28a570))
* support tags completion ([fd08802](https://github.com/wsdjeg/zettelkasten.nvim/commit/fd08802d9106fd03942e4b2edd87d6f9f87ac20c))
* use ctrl-y to insert note id from picker ([72672fd](https://github.com/wsdjeg/zettelkasten.nvim/commit/72672fd5c49e9b1d6c204fa4613dd8c11f029291))


### Bug Fixes

* add chinese description ([3ff8f91](https://github.com/wsdjeg/zettelkasten.nvim/commit/3ff8f917a785d88ab654d88e611973cc31b4b3b6))
* add empty line after tags line ([25ccd0c](https://github.com/wsdjeg/zettelkasten.nvim/commit/25ccd0cccf62485643a787e962939f62379895fe))
* add missing is_float function ([8a398f4](https://github.com/wsdjeg/zettelkasten.nvim/commit/8a398f4b61a202548b80b07b6293b7225261d957))
* fix zettelkasten note time ([9292816](https://github.com/wsdjeg/zettelkasten.nvim/commit/92928168480c4f1b9684b0ea1cc94978b76156d2))
* improve description ([8f432ea](https://github.com/wsdjeg/zettelkasten.nvim/commit/8f432ea3c0c421313f0d3f429cf5c95c4deac99c))
* use browse api instead of command ([315b119](https://github.com/wsdjeg/zettelkasten.nvim/commit/315b119cd50e0a0cf6c8e9d0d7e35122c8c9887a))
* use lua function in telescope extension ([1dfb089](https://github.com/wsdjeg/zettelkasten.nvim/commit/1dfb089e8506410e98532ba0de644f91200de98a))
* use vim.cmd ([dd830fd](https://github.com/wsdjeg/zettelkasten.nvim/commit/dd830fdbc51912ab863883afab9b20248eddb524))

## [2.1.0](https://github.com/wsdjeg/zettelkasten.nvim/compare/v2.0.0...v2.1.0) (2025-11-23)


### Features

* add luarocks support ([fa2b4f5](https://github.com/wsdjeg/zettelkasten.nvim/commit/fa2b4f553a02d6e67716ac3ae66d9714c10f7f0f))
* add zk templates source ([7654459](https://github.com/wsdjeg/zettelkasten.nvim/commit/7654459b78b722810fec29ccdf7b11530727f212))
* use lua syntax file ([c0a5d0b](https://github.com/wsdjeg/zettelkasten.nvim/commit/c0a5d0b07382a59480553378252c4bcaa63a289f))


### Bug Fixes

* fix default action of zettelkasten_template ([52d811d](https://github.com/wsdjeg/zettelkasten.nvim/commit/52d811d14d044047f8c7615cef08b75030b2fccf))

## [2.0.0](https://github.com/wsdjeg/zettelkasten.nvim/compare/v1.0.0...v2.0.0) (2025-11-09)


### ⚠ BREAKING CHANGES

* use setup instead of vim.g.var

### Features

* add notify function ([5874e1f](https://github.com/wsdjeg/zettelkasten.nvim/commit/5874e1fc9561fe89f1aacd8ffdf2a39224e3512b))
* add option to set completion kind ([0a7ccc6](https://github.com/wsdjeg/zettelkasten.nvim/commit/0a7ccc69b7e12905b349aa010ad17f03e43c2e95))
* add zettelkasten source for picker.nvim ([f7e4da4](https://github.com/wsdjeg/zettelkasten.nvim/commit/f7e4da4c593f5a34d72bb8ce92c2deb9cc93a145))
* add zettelkasten_tags source ([f9d4761](https://github.com/wsdjeg/zettelkasten.nvim/commit/f9d4761b224511ae5122159049ccff8129dbe398))
* enable notify highlight ([41a90ea](https://github.com/wsdjeg/zettelkasten.nvim/commit/41a90ea7b0d0113722ef4d17f4ca55855d4e6922))
* improve ZkHover command ([62ddf8f](https://github.com/wsdjeg/zettelkasten.nvim/commit/62ddf8f88d3af245506b6aa95412e78a12390a9c))
* support zk tags preview ([448fae3](https://github.com/wsdjeg/zettelkasten.nvim/commit/448fae3579fa91f7c9445ce852732aea31b791d2))
* use `<F2>` to toggle zettelkasten tag tree ([f7c7fe2](https://github.com/wsdjeg/zettelkasten.nvim/commit/f7c7fe2f02606b9a34f2344bea139602ce54a550))
* use api function instead of vim.cmd ([b85dcf4](https://github.com/wsdjeg/zettelkasten.nvim/commit/b85dcf413be3197a81fa5a33bf9c93a1ff2e1e36))
* use setup instead of vim.g.var ([ce3212e](https://github.com/wsdjeg/zettelkasten.nvim/commit/ce3212efc20615b756ddb4d662fe669f17e5f03e))


### Bug Fixes

* fix completion_kind setup ([6e78379](https://github.com/wsdjeg/zettelkasten.nvim/commit/6e78379102d7cad2d367b083e26c4274076504e5))
* fix highlight range ([d44106b](https://github.com/wsdjeg/zettelkasten.nvim/commit/d44106b9942b70c14b82b2b73f5faf1ed76d766e))
* fix setup function ([0342f65](https://github.com/wsdjeg/zettelkasten.nvim/commit/0342f65337e270ebfdb0de29471f185ee51cea7f))
* fix wrong key ([ae94168](https://github.com/wsdjeg/zettelkasten.nvim/commit/ae94168baf96871ff3010c1d9f5a11440062459d))
* fix zettelkasten browser ftdetect ([b7fcad9](https://github.com/wsdjeg/zettelkasten.nvim/commit/b7fcad9a8948ae10d109b1e88a5ecc6f5004327b))
* fix zknew completion ([e9d8946](https://github.com/wsdjeg/zettelkasten.nvim/commit/e9d89463e3a4c0ed3737e345bfcfd916e07e221a))
* make read_note return table ([b663938](https://github.com/wsdjeg/zettelkasten.nvim/commit/b663938e1151c33e2bae11d2b5832f4d930df780))
* only set zk ftplugin for zettelkasten file ([760f354](https://github.com/wsdjeg/zettelkasten.nvim/commit/760f3540bb74aa183967f9522f79628f4afb2c74))
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
