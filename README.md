AWS Elastic Beanstalk入門
===
# 目的
# 前提
| ソフトウェア     | バージョン    | 備考         |
|:---------------|:-------------|:------------|
| AWS Elastic Beanstalk  |API Version 2010-12-01   |             |
| Ruby      　　　| 2.1.2       |             |
| Python         | 2.7.5       |             |
| hazel          | 0.0.8       |             |

+ [アクセスキーID設定済み](https://github.com/k2works/aws_security_introduction)

# 構成
+ [セットアップ](#0)
+ [Rails アプリケーションの AWS Elastic Beanstalk へのデプロイ](#1)
+ [Sinatra アプリケーションの AWS Elastic Beanstalk へのデプロイ](#2)
+ [Ruby 環境のカスタマイズと設定](#3)
+ [Ruby での Amazon RDS の使用](#4)
+ [Ruby での VPC の使用](#5)

# 詳細
## <a name="0">セットアップ</a>
### ebセットアップ

```bash
$ wget https://s3.amazonaws.com/elasticbeanstalk/cli/AWS-ElasticBeanstalk-CLI-2.6.3.zip
$ unzip AWS-ElasticBeanstalk-CLI-2.6.3.zip
$ cp -r AWS-ElasticBeanstalk-CLI-2.6.3/eb /usr/local/
$ export PATH=$PATH:/usr/local/eb/macosx/python2.7/
```

### AWS DevToolsセットアップ

_fooapp_

```bash
$ wget https://s3.amazonaws.com/elasticbeanstalk/cli/AWS-ElasticBeanstalk-CLI-2.6.3.zip
$ cp -r AWS-ElasticBeanstalk-CLI-2.6.3/AWSDevTools /usr/local/
```

### botoセットアップ

```bash
$ sudo pip install boto
```

## <a name="1">Rails アプリケーションの AWS Elastic Beanstalk へのデプロイ</a>

### Rails アプリケーションの作成

```bash
$ rails new fooapp
$ cd fooapp
```

### Git リポジトリの設定

```bash
$ git init && git add -A && git commit -m "Initial commit"
```

### AWS Elastic Beanstalk の設定

```bash
$ eb init
・・・
$ eb start
Starting application "fooapp".
Would you like to deploy the latest Git commit to your environment? [y/n]: y

Waiting for environment "fooapp-env" to launch.
2014-10-10 15:40:00     INFO    createEnvironment is starting.
2014-10-10 15:40:05     INFO    Using elasticbeanstalk-ap-northeast-1-262470114399 as Amazon S3 storage bucket for environment data.
2014-10-10 15:40:34     INFO    Created EIP: 54.249.242.128
2014-10-10 15:40:35     INFO    Created security group named: awseb-e-vtt2jy47na-stack-AWSEBSecurityGroup-1DYZF4TKYOAYG
2014-10-10 15:41:42     INFO    Waiting for EC2 instances to launch. This may take a few minutes.
2014-10-10 15:45:40     INFO    Application available at fooapp-env-unbndwrs9f.elasticbeanstalk.com.
2014-10-10 15:45:40     INFO    Successfully launched environment: fooapp-env
Application is available at "fooapp-env-unbndwrs9f.elasticbeanstalk.com".
```

### 本番環境変数追加

```bash
$ rake secret
5f7d10669f7dec9328825965a6ed265169532d330b23fc4908bf030d6b96709efab0f1f897173624e255dba0402e3ddeb9bc3cbec97b0b8ffae92f68f4f99b43
```
_fooapp/.elasticbeanstalk/optionsettings.fooapp-env_

```
・・・
[aws:elasticbeanstalk:application:environment]
BUNDLE_WITHOUT=test:development
PARAM1=
PARAM2=
PARAM3=
PARAM4=
PARAM5=
RACK_ENV=production
RAILS_SKIP_ASSET_COMPILATION=false
RAILS_SKIP_MIGRATIONS=false
SECRET_KEY_BASE=5f7d10669f7dec9328825965a6ed265169532d330b23fc4908bf030d6b96709efab0f1f897173624e255dba0402e3ddeb9bc3cbec97b0b8ffae92f68f4f99b43
・・・
```

```bash
$ eb update
```

### アプリケーションの表示

```bash
$ eb status --verbose
Retrieving status of environment "fooapp-env".
URL             : fooapp-env-unbndwrs9f.elasticbeanstalk.com
Status          : Ready
Health          : Green
Environment Name: fooapp-env
Environment ID  : e-vtt2jy47na
Environment Tier: WebServer::Standard::1.0
Solution Stack  : 64bit Amazon Linux 2014.03 v1.0.7 running Ruby 2.1 (Puma)
Version Label   : git-4e2fcc53a1997d2fc38c4d78aa1e299868005a86-1412923196427
Date Created    : 2014-10-10 15:40:01
Date Updated    : 2014-10-10 15:45:40
Description     :
$ open http://fooapp-env-unbndwrs9f.elasticbeanstalk.com
```

### アプリケーションの更新

#### Rails を使用するようにサンプルアプリケーションを更新するには

```bash
$ git add .gitignore && git commit -m "Ignore .elasticbeanstalk from Git"
$ git aws.push
```


```bash
$ rails g scaffold article url:string title:string category:string published:date access:integer comments_count:integer losed:boolean
$ rake db:migrate
```

_fooapp/config/routes.rb_

```ruby
root 'articles#index'
```

```bash
$ git add .
$ git commit -am "Create Application"
$ git aws.push
```
#### Amazon RDS を使用するようにサンプルアプリケーションを更新するには

_fooapp/config/database.yml_

```yml
production:
  adapter: mysql2
  encoding: utf8
  database: <%= ENV['RDS_DB_NAME'] %>
  username: <%= ENV['RDS_USERNAME'] %>
  password: <%= ENV['RDS_PASSWORD'] %>
  host: <%= ENV['RDS_HOSTNAME'] %>
  port: <%= ENV['RDS_PORT'] %>
```

_fooapp/Gemfile_

```ruby
gem 'mysql2'
```

```bash
$ git add .
$ git commit -m "update database"
$ git aws.push
```

### クリーンアップ

#### アプリケーションを削除するには

```bash
$ eb stop
```

## <a name="2">Sinatra アプリケーションの AWS Elastic Beanstalk へのデプロイ</a>

_fooapp_sinatra_

### Sinatra アプリケーションの作成

```bash
$ hazel fooapp_sinatra
$ cd fooapp_sinatra
```

### Git リポジトリの設定

```bash
$ git init && git add -A && git commit -m "Initial commit"
```

### AWS Elastic Beanstalk の設定

```bash
$ eb init
```

### アプリケーションの作成

```bash
eb start
```

このままだと_config/initializers_フォルダがレポジトリに含まれずエラーになるのでレポジトリに空フォルダを追加

```bash
$ touch config/initializers/.gitkeep
$ git commit -am "add folder"
$ git aws.push
```

### アプリケーションの表示

```bash
$ eb status --verbose
Retrieving status of environment "production".
URL             : production-bspwdwmpxe.elasticbeanstalk.com
Status          : Ready
Health          : Green
Environment Name: production
Environment ID  : e-8unr2xqse9
Environment Tier: WebServer::Standard::1.0
Solution Stack  : 64bit Amazon Linux 2014.03 v1.0.7 running Ruby 2.1 (Passenger Standalone)
Version Label   : git-aee0edd5922790e2b0986b729e1c0f628798c7cb-1412931658208
Date Created    : 2014-10-10 17:41:16
Date Updated    : 2014-10-10 18:01:19
Description     :
$ open http://production-bspwdwmpxe.elasticbeanstalk.com
```

### クリーンアップ

```bash
$ eb stop
$ eb delete
```

## <a name="3">Ruby 環境のカスタマイズと設定</a>

_split-sinatra-example_

```bash
$ git clone https://github.com/andrew/split-sinatra-example.git
$ cd sqplit-sinatra-example
$ eb init
```

_split-sinatra-example/.ebextensions/myapp.config_

```
packages:
  yum:
    git: []
commands:
  redis_build:
    command: yum -y --enablerepo=epel install redis
services:
  sysvinit:
    redis:
      enabled: true
      ensureRunning: true
container_commands:
  bundle_install:
    command: bundle install --deployment
```

```bash
$ git add .
$ git commit -am "add myapp.config"
$ eb start
```

## <a name="4">Ruby での Amazon RDS の使用</a>
## <a name="5">Ruby での VPC の使用</a>

# 参照

* [AWS Elastic Beanstalk](http://docs.aws.amazon.com/ja_jp/elasticbeanstalk/latest/dg/Welcome.html)
* [Hazel](http://c7.github.io/hazel/)
* [is not checked out… bundle install does NOT fix help!](http://stackoverflow.com/questions/6648870/is-not-checked-out-bundle-install-does-not-fix-help)
* [RDS付きのBeanstalkを使う際の注意点](http://blog.serverworks.co.jp/tech/2013/03/12/rds_on_beanstalk/)
