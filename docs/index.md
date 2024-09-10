# 浙江大学24年秋冬操作系统实验

本[仓库](https://github.com/ZJU-SEC/os24fall-stu)是浙江大学24年秋冬**操作系统**课程的教学仓库，包含在操作系统课程上所有的实验文档和公开代码。仓库目录结构：

```bash
├── README.md
├── docs/       # 实验文档   
├── mkdocs.yml
└── src/        # 公开代码
```

实验文档已经部署在了[GitHub Pages](https://zju-sec.github.io/os24fall-stu/)上，方便大家阅读。


## 本地渲染文档

文档采用了 [mkdocs-material](https://squidfunk.github.io/mkdocs-material/) 工具构建和部署。如果想在本地渲染：

```text
$ pip3 install mkdocs-material mkdocs-heti-plugin==0.1.6   # 安装 mkdocs 及插件
$ git clone https://github.com/ZJU-SEC/os24fall-stu        # clone 本 repo
$ mkdocs serve                                             # 本地渲染
INFO     -  Building documentation...
INFO     -  Cleaning site directory
...
INFO     -  [11:00:57] Serving on http://127.0.0.1:8000/os24fall-stu/
```

## 致谢

感谢以下各位老师和助教的辛勤付出！

[申文博](https://wenboshen.org/)、[周亚金](https://yajin.org/)、徐金焱、周侠、管章辉、张文龙、刘强、孙家栋、周天昱、庄阿得、王琨、沈韬立、王星宇、朱璟森、谢洵、[潘子曰](https://pan-ziyue.github.io/)、朱若凡、季高强、郭若容、杜云潇、吴逸飞、李程浩、朱家迅、王行楷、陈淦豪、赵紫宸、[王鹤翔](https://tonycrane.cc)、许昊瑞。

