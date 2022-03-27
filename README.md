# www.maeda-m.com

Source for GitHub Pages site using Jekyll.

## New Post

### Overview

1. Start Jekyll
2. Create new branche and file
3. Add content
4. Preview a post
5. Publish a post
6. Stop Jekyll

### 1. Start Jekyll

```
$ docker-compose up -d
$ docker-compose exec ruby bash
```

### 2. Create new branche and file

```
# git checkout -b new-branche
# touch /jekyll/docs/_posts/$(date '+%Y-%m-%d')-awesome-article-title.md
```

`e.g. docs/_posts/2022-03-14-awesome-article-title.md`

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

- [Create Commit](https://docs.github.com/ja/pull-requests/committing-changes-to-your-project/creating-and-editing-commits)
```
# git add docs/_posts/yyyy-mm-dd-awesome-article-title.md
# git commit
```
- [Creating pull request](https://docs.github.com/ja/pull-requests/collaborating-with-pull-requests/proposing-changes-to-your-work-with-pull-requests)
```
# git push -u origin new-branche
```
- Check items before publication
- [Merge changes from pull request](https://docs.github.com/ja/pull-requests/collaborating-with-pull-requests/incorporating-changes-from-a-pull-request)
  - `NOTE: After pull request is merged, the branch is automatically deleted.`
- Sync the base branch
```
# git switch main
# git pull origin main
```

### 6. Stop Jekyll

```
# exit
$ docker-compose down
```

## Linting

See: [textlint](https://github.com/textlint/textlint)
