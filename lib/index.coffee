
Sequelize = require "sequelize"

sequelize = new Sequelize("postgres://:@localhost:5432/xcmy")

sequelize.authenticate()
  .then ()->
    console.log("db Connected success")
  .catch (err)->
    console.log("db connected fail with err :"+err)


module.exports.Sequelize = Sequelize
module.exports.sequelize = sequelize