koa = require("koa")
app = new koa()
Router = require("koa-router")
bodyParser = require("koa-bodyparser")

#koa-body-parser初始化
app.use bodyParser()

#创建一个路由
router = new Router prefix:'/api'

#子路由
user = require("./apis/user")
#装载子路由
router.use user.routes(),user.allowedMethods()

#加载路由中间件
app.use router.routes()

app.use (ctx)->
  ctx.body = "hello koa2"


require("./lib")

app.listen 3000,(err)->
  console.log("server start #{err or "success"}")