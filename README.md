# blog.maeda-m.com

Source for GitHub Pages site using Jekyll.

## New Post

### Overview

1. Start Jekyll
2. Create a new file
3. Add content
4. Preview a post
5. Publish a post
6. Stop Jekyll

### 1. Start Jekyll

```
$ docker-compose up -d
$ docker-compose exec ruby bash
```

### 2. Create a new file

```
# touch /jekyll/pages/_posts/$(date '+%Y-%m-%d')-awesome-article-title.md
```

`e.g. pages/_posts/2022-03-14-awesome-article-title.md`

### 3. Add content

```markdown
---
layout: post
title: "Awesome article title!"
date:  2022-03-14 13:10:27 +0900
---

:+1: Awesome content!

```

### 4. Preview a post

http://localhost:4000

### 5. Publish a post

```
$ git add pages/_posts/yyyy-mm-dd-awesome-article-title.md
$ git commit
$ git push -u origin main
```

### 6. Stop Jekyll

```
# exit
$ docker-compose down
```

## Linting

See: [textlint](https://github.com/textlint/textlint)
