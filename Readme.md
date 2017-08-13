# 一个基于coffee + postgresql + koa2 的服务端项目demo


## 目录

- [基础环境配置](#基础环境)
- [项目搭建](#项目搭建)
- [数据库配置](#数据库配置)
- [创建数据库模型](#创建数据库模型)
- [创建子路由文件](#创建子路由文件)
- [路由配置](#路由配置)
- [接口测试](#接口测试)
---


## 基础环境配置

#### 开发工具
[**Webstorm 2017**](https://www.jetbrains.com/webstorm/)版，如何破解移步<http://idea.lanyus.com/>

#### 服务器环境配置

##### [**Node.js环境**](https://nodejs.org/zh-cn/)（因为`7.10.0`版本相对稳定，支持也比较好，所以没有用最新版）

    $ node -v
    v7.10.0
##### [**CoffeeScript安装**](http://coffeescript.org/v2/#top)

    //安装
    $ npm install -g coffeescript@next
    
    //版本
    $ coffee -v
    CoffeeScript version 2.0.0-beta2
    
    
#### 数据库环境

##### [**PostgreSQL 安装**](https://www.postgresql.org/) 

使用[**Postgres.app**](http://postgresapp.com/)安装PostgreSQL，版本为`9.6.0`


#### 其他（非必须）

- ##### Mac端调试工具 [**iTerm2**](http://www.iterm2.com/) 下载直接使用。

- ##### 接口调试工具[**HTTPie**](https://httpie.org/),
GitHub地址<https://github.com/jakubroztocil/httpie>
    
    //安装
    $ brew install httpie

---
## 项目搭建


- 使用**WebStorm**创建一个空项目kcpDemo
- 创建一个入口文件`index.coffee`
- 创建[***package.json文件***](http://javascript.ruanyifeng.com/nodejs/packagejson.html#toc4)。（`package.json`文件可以手工编写，也可以使用`npm init`命令自动生成，输入名字和`main`文件`index.coffee`，注意名字不能大写，其余按回车自动生成）。

        //到项目根目录下  
        $ cd kcpDemo  
        $ npm init  
    
生成的`package.json`文件如下

```json
{
  "name": "kcpdemo",
  "version": "1.0.0",
  "description": "",
  "main": "index.coffee",
  "scripts": {
    "test": "echo \"Error: no test specified\" && exit 1"
  },
  "author": "",
  "license": "ISC"
}
```

- 模块安装

1. [**koa2安装**](http://koajs.com/)



        $ npm install --save koa 

2. [**Sequelize安装**](http://docs.sequelizejs.com/)

    
        $ npm install --save sequelize
        //驱动
        $ npm install --save pg pg-hstore
    

3. [***validator.js数据验证***](https://github.com/chriso/validator.js)


        //在项目根目录下
        $ npm install --save validator

    
    
- 在`index.js`文件中创建启动代码


```coffeescript
koa = require("koa")
app = new koa()

app.use (ctx)->
  ctx.body = "hello koa2"

app.listen 3000,(err)->
  console.log("server start #{err or "success"}")
```

- 启动服务


        //根目录下启动项目
        $ coffee  index.coffee
        server start success


- 测试

```Shell
$ http :3000
HTTP/1.1 200 OK
Connection: keep-alive
Content-Length: 10
Content-Type: text/plain; charset=utf-8
Date: Sat, 12 Aug 2017 01:14:01 GMT

hello koa2
```
可以看到成功输出 `hello koa2`，服务创建成功。


##  数据库配置

以上只是一个简单的hello word服务程序，并没有与数据库有任何关系，下面来配置数据库。

- 用postgres创建一个数据库`xcmy`(名字随便起)
- 在根目录下创建一个文件夹lib，用来保存数据模型，在lib下创建`index.coffee`来初始化数据库。

```coffeescript
#index.coffee文件
Sequelize = require "sequelize"

sequelize = new Sequelize("postgres://:@localhost:5432/xcmy")

sequelize.authenticate()
  .then ()->
    console.log("db Connected success")
  .catch (err)->
    console.log("db connected fail with err :"+err)

module.exports.Sequelize = Sequelize
module.exports.sequelize = sequelize
```

- 在根目录下index.coffee文件中引入数据库初始化。

```coffeescript
koa = require("koa")
app = new koa()

app.use (ctx)->
  ctx.body = "hello koa2"

#数据库初始化
require("./lib")

app.listen 3000,(err)->
  console.log("server start #{err or "success"}")
```

- 重新启动


```Shell
$ coffee  index.coffee
server start success
db Connected success
```

## 创建数据库模型

- 在lib下创建一个数据模型文件`user.coffee`


```
__lib
  |__index.coffee
  |__user.coffee
__package.json
__index.coffee

```


- 然后创建一个User的数据模型。



```coffeescript
Sequelize = require("../lib").Sequelize
sequelize = require("../lib").sequelize

User = sequelize.define "user",
  {
    realName:{
      type:Sequelize.STRING,
      allowNull:false
    },
    gender:{
      type:Sequelize.ENUM,
      values:["female","male"],
      allowNull:false
    },
    birthday:{
      type:Sequelize.DATEONLY
    }
    email:{
      type:Sequelize.STRING
      validate:{
        isEmail:{
          msg:"邮箱格式不正确"
        }
      }
    },
    headImg:{
      type:Sequelize.STRING
      defaultValue:"http://csdn/img/6788867675685.jpg"
    },
    height:{
      type:Sequelize.FLOAT
      validate:{
        min:{
          args:70
          msg:"身高不得低于70cm"
        }
        max:{
          args:230
          msg:"身高不得高于230cm"
        }
      }
    },
    weight:{
      type:Sequelize.FLOAT
      defaultValue:60
    }
  },
  {
    timestamps:true,
    paranoid:true,
    underscored:false,
  }
User.sync()
module.exports = User

```


## 创建子路由文件

- 安装 [***koa-router中间件***](https://github.com/alexmingoia/koa-router)和 [***koa-bodyparser中间件***](https://github.com/koajs/bodyparser)
    

    //路由设置和请求数据获取模块
    npm install --save koa-router koa-bodyparser

- 在根目录下创建文件夹*apis*，在其下创建一个文件`user.coffee`，现在项目目录如下

```
__apis
  |__user.coffee
__lib
  |__index.coffee
  |__user.coffee
__package.json
__index.coffee

```
- 在`user.coffee`中创建User模型的数据接口


```coffeescript
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
```


## 路由配置


- 在入口文件`index.coffee`配置路由

```coffeescript
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
```

## 接口测试

- 初始化数据模型，重启项目

```Shell
$ coffee  index.coffee
server start success
Executing (default): SELECT 1+1 AS result
Executing (default): SELECT t.typname enum_name, array_agg(e.enumlabel ORDER BY enumsortorder) enum_value FROM pg_type t JOIN pg_enum e ON t.oid = e.enumtypid JOIN pg_catalog.pg_namespace n ON n.oid = t.typnamespace WHERE n.nspname = 'public' AND t.typname='enum_users_gender' GROUP BY 1
db Connected success
Executing (default): CREATE TYPE "public"."enum_users_gender" AS ENUM('female', 'male');
Executing (default): CREATE TABLE IF NOT EXISTS "users" ("id"   SERIAL , "realName" VARCHAR(255) NOT NULL, "gender" "public"."enum_users_gender" NOT NULL, "birthday" DATE, "email" VARCHAR(255), "headImg" VARCHAR(255) DEFAULT 'http://csdn/img/6788867675685.jpg', "height" FLOAT, "weight" FLOAT DEFAULT 60, "createdAt" TIMESTAMP WITH TIME ZONE NOT NULL, "updatedAt" TIMESTAMP WITH TIME ZONE NOT NULL, "deletedAt" TIMESTAMP WITH TIME ZONE, PRIMARY KEY ("id"));
Executing (default): SELECT i.relname AS name, ix.indisprimary AS primary, ix.indisunique AS unique, ix.indkey AS indkey, array_agg(a.attnum) as column_indexes, array_agg(a.attname) AS column_names, pg_get_indexdef(ix.indexrelid) AS definition FROM pg_class t, pg_class i, pg_index ix, pg_attribute a WHERE t.oid = ix.indrelid AND i.oid = ix.indexrelid AND a.attrelid = t.oid AND t.relkind = 'r' and t.relname = 'users' GROUP BY i.relname, ix.indexrelid, ix.indisprimary, ix.indisunique, ix.indkey ORDER BY i.relname;
```

**User**模型初始化成功（上面显示的是使用postgresql创建User表的命令）

- User创建


```Shell
//若参数不合法
$ http :3000/api/user/create realName=小明 gender=male birthday=1993-09-09 email=xcmy@163.com height=60
HTTP/1.1 200 OK
Connection: keep-alive
Content-Length: 178
Content-Type: application/json; charset=utf-8
Date: Sat, 12 Aug 2017 12:13:01 GMT

{
    "err": {
        "errors": [
            {
                "__raw": {},
                "message": "身高不得低于70cm",
                "path": "height",
                "type": "Validation error",
                "value": "60"
            }
        ],
        "name": "SequelizeValidationError"
    },
    "msg": "未知错误"
}
//创建成功
$ http :3000/api/user/create realName=小明 gender=male birthday=1993-09-09 email=xcmy@163.com height=170
HTTP/1.1 200 OK
Connection: keep-alive
Content-Length: 257
Content-Type: application/json; charset=utf-8
Date: Sat, 12 Aug 2017 12:11:13 GMT

{
    "birthday": "1993-09-09",
    "createdAt": "2017-08-12T12:11:13.013Z",
    "deletedAt": null,
    "email": "xcmy@163.com",
    "gender": "male",
    "headImg": "http://csdn/img/6788867675685.jpg",
    "height": 170,
    "id": 1,
    "realName": "小明",
    "updatedAt": "2017-08-12T12:11:13.013Z",
    "weight": 60
}


```
- User获取，从上面看到创建了一个id=1的用户

```Shell
//单个用户
$ http :3000/api/user/get/1
HTTP/1.1 200 OK
Connection: keep-alive
Content-Length: 257
Content-Type: application/json; charset=utf-8
Date: Sat, 12 Aug 2017 12:15:19 GMT

{
    "birthday": "1993-09-09",
    "createdAt": "2017-08-12T12:11:13.013Z",
    "deletedAt": null,
    "email": "xcmy@163.com",
    "gender": "male",
    "headImg": "http://csdn/img/6788867675685.jpg",
    "height": 170,
    "id": 1,
    "realName": "小明",
    "updatedAt": "2017-08-12T12:11:13.013Z",
    "weight": 60
}
//用户列表
$ http :3000/api/user/list
HTTP/1.1 200 OK
Connection: keep-alive
Content-Length: 259
Content-Type: application/json; charset=utf-8
Date: Sat, 12 Aug 2017 12:17:12 GMT

[
    {
        "birthday": "1993-09-09",
        "createdAt": "2017-08-12T12:11:13.013Z",
        "deletedAt": null,
        "email": "xcmy@163.com",
        "gender": "male",
        "headImg": "http://csdn/img/6788867675685.jpg",
        "height": 170,
        "id": 1,
        "realName": "小明",
        "updatedAt": "2017-08-12T12:11:13.013Z",
        "weight": 60
    }
]
```

- 删除用户


```shell
$ http DELETE :3000/api/user/delete/2
HTTP/1.1 200 OK
Connection: keep-alive
Content-Length: 37
Content-Type: application/json; charset=utf-8
Date: Sat, 12 Aug 2017 12:21:34 GMT

{
    "msg": "成功删除id为1的数据"
}
```










