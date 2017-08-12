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