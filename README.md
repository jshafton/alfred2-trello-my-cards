# Alfred 2 Workflow - My (Open) Trello Cards

## API token

You need a Trello API token to use this thing. Go to this url:

https://trello.com/1/connect?key=1567f19970db62213b78fe1482cff991&name=Alfred2+My+Trello+Cards&response_type=token&scope=read,write&expiration=never

and save the output as your token.

Either set this value in an environment variable for `TRELLO_USER_TOKEN` or create
`~/.alfred-my-trello-cards.yml` with the following:

```yml
---

user_token: 'YOUR_API_TOKEN'
```
