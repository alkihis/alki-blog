# alki-blog

Personal blog.

Available on [alkihis.fr](https://alkihis.fr).

This blog is based on [Hexo](https://hexo.io).

## Init

```sh
docker-compose build blog
docker-compose run blog yarn
```

## Expose server

```sh
docker-compose up blog
```

Server is exposed on `localhost:5001`.

## New article

### From hexo instance on the container

```sh
docker-compose exec blog yarn hexo new post "Article name"
# You might need to change owner of file
sudo chown <user>:<user> source/_posts/<article-slug>.md
```

### From local hexo

If you have hexo installed on your system (`npm i -g hexo-cli`).

```sh
hexo new post "Article name"
```
