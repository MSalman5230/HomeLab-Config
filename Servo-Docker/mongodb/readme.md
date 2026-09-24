use admin
db.createUser({
  user: "huruhuru",
  pwd: "changeme",
  roles: [
    { role: "readWrite", db: "gamelootScrape" }
  ]
})


db.grantRolesToUser(
  "huruhuru",
  [{ role: "readWrite", db: "cmr" }]
)