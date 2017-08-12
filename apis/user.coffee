router = require("koa-router")({prefix:"/user"})
validator = require("validator")
User = require("../lib/user")

#验证接口中的id是否合法
router.param "id",(value,ctx,next)->
  return ctx.body = {msg:"id 不合法"} if not validator.isInt(value)
  next()

#User创建接口
router.post "/create",(ctx)->
  try
    ctx.body = await User.create(ctx.request.body)
  catch err
    ctx.body = {msg:"未知错误",err:err}

#User单个查询接口
router.get "/get/:id",(ctx)->
  try
    ctx.body = await User.findOne({where:{id:ctx.params.id}})
  catch err
    ctx.body = {msg:"未知错误",err:err}

#User列表查询
router.get "/list",(ctx)->
  try
    ctx.body = await User.findAll()
  catch err
    ctx.body = {msg:"未知错误",err:err}

#删除接口
router.delete "/delete/:id",(ctx)->
  try
    ctx.body = {msg:"成功删除id为#{await User.destroy({where:{id:ctx.params.id}})}的数据"}
  catch err
    ctx.body = {msg:"未知错误",err:err}

#表删除
router.get "/drop",(ctx)->
  try
    ctx.body = await User.drop()
  catch err
    ctx.body = {msg:"未知错误",err:err}


module.exports = router