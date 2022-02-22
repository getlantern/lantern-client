Running a json-server for serving dummy data. Used for testing Replica.

# Usage
- Install [json-server](https://github.com/typicode/json-server)
  - `npm install -g json-server`
- Run it in a separate window
  - `json-server --watch replica_db.json --routes replica_routes.json`
- Here're a couple of test requests (and their responses) taken directly from a real lantern-desktop instances running Replica:
  - Searching web
    - `curl -XGET 'http://localhost:3000/replica/search/serp_web?s=aaa&offset=0&lang=en'`
  - Searching videos
    - `curl -XGET 'http://localhost:3000/replica/search?s=aaa&offset=0&orderBy=relevance&lang=en&type=video%2Fmp4+video%2Fwebm+video%2Fogg+video%2Fmov'`
  - Searching audios
    - `curl -XGET 'http://localhost:3000/replica/search?s=aaaa&offset=0&orderBy=relevance&lang=en&type=audio+music+x-music'`
  - Searching images
    - `curl -XGET 'http://localhost:3000/replica/search?s=toto&offset=0&orderBy=relevance&lang=en&type=image'`

