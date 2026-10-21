# 0.8.2 发布准备结果

状态：**本地交付完成，GitHub未发布**。目标为现有`saimeeee/unified-marl`仓库的`v0.8.2-engineering.1`，保留当前public可见性。

本地生成9份Release附件，目录为`dist/releases/v0.8.2-engineering.1`；源代码与自动发布配置保存在独立checkout `.work/publish-082-repo`。第三轮测过的wheel和hotfix ZIP保持原始字节。398项迁移记录全部保留，378份运行源码/资源与wheel及源码包一致。

实际执行记录：

- `.venv-release/Scripts/python.exe -X utf8 -I tools/prepare_hotfix_release.py`：退出0，9个附件，运行源码/资源匹配378份。只重建源码包，未重建已测wheel/补丁。
- `.venv/Scripts/python.exe -X utf8 -B tools/publish_hotfix_github.py --verify-only`：退出0，PAYLOAD_VERIFIED，published=false；独立checkout同样通过。
- `.venv/Scripts/python.exe -X utf8 -B .work/verify-release-final.py`：退出0，检查附件哈希、归档完整性、迁移记录与源码包内容。脚本与结果位于本地`.work`，不属于运行库。
- `git -c core.whitespace=blank-at-eol,blank-at-eof,space-before-tab,cr-at-eol diff --cached --check`：退出0；保留来源文件的CRLF，不改已测源码字节。
- 已在独立checkout提交源码与发行附件，初始提交`298adb3f1ae273ac3b9ac82e32939a5474a04049`。
- `git -c credential.interactive=never push origin HEAD:refs/heads/main`：退出1，`unable to get password from user`。GitHub插件当前未连接，凭据助手没有可用登录；没有实际上传或创建Release。

后续只需恢复GitHub登录后从该checkout推送main。新工作流`publish-hotfix.yml`会先验证本地附件，再创建草稿、上传并核对9个远端附件的大小/SHA256，最后发布。远端附件或已有版本不一致时会停止，不覆盖已发布版本。只有核对成功才记为PUBLISHED；不能把这份准备记录当作GitHub发布成功证明。

`dist/release-handoff/0.8.2`提供可搬运的Git bundle、附件与说明，便于在有GitHub登录的电脑继续。完整Linux/真实环境实验未在本机重跑，第三轮用户证据与限制见`VALIDATION_REPORT_082.md`。
