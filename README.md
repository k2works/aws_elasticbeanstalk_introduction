AWS Elastic Beanstalk入門
===
# 目的
AWS Elastic Beanstalkの使用方法を修得する。

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

### セットアップ
```bash
$ hazel fooapp_rds
$ cd fooapp_rds
```
### sinatra-activerecordセットアップ
_fooapp_rds/Gemfile_
```ruby
gem "sinatra-activerecord"
gem "sqlite3"
```

_fooapp_rds/fooapp_rds.rb_
```ruby
require "sinatra/activerecord"

class FooappRds < Sinatra::Base
  register Sinatra::ActiveRecordExtension
  set :database, {adapter: "sqlite3", database: "foo.sqlite3"}
  set :public_folder => "public", :static => true

  get "/" do
    erb :welcome
  end
end
```
_fooapp_rds/Rakefile_

```ruby
require "sinatra/activerecord/rake"

namespace :db do
  task :load_config do
    require "./fooapp_rds"
  end
end
```

```bash
$ bundle
$ rake -T
```

### データベース作成
```bash
$ rake db:create_migration NAME=create_users
db/migrate/20141013044321_create_users.rb
```

_fooapp_rds/db/migrate/20141013044321_create_users.rb_

```ruby
class CreateUsers < ActiveRecord::Migration
  def change
      create_table :users do |t|
      t.string :name
    end
  end
end
```

```bash
$ rake db:migrate
== 20141013044321 CreateUsers: migrating ======================================
-- create_table(:users)
   -> 0.0024s
== 20141013044321 CreateUsers: migrated (0.0026s) =============================
```

### モデルを作成
_fooapp_rds/fooapp_rds.rb_
```ruby
class User < ActiveRecord::Base
  validates_presence_of :name
end
```

### データアクセスロジック作成
```ruby
get '/users' do
  @users = User.all
  erb :welcome
end

get '/users/:id' do
  @user = User.find(params[:id])
  erb :welcome
end
```

### 実行環境の整備
_fooapp_rds/Gemfile_

```ruby
gem 'guard-shotgun', :git => 'https://github.com/rchampourlier/guard-shotgun.git'
gem "rack-livereload"
gem 'guard-livereload', require: false
```

_fooapp_rds/config.ru_

```ruby
# Rack LiveReload
require 'rack-livereload'
use Rack::LiveReload
```

```bash
$ bundle
$ guard init shotgun
$ guard init livereload
```

_fooapp_rds/Guardfile_

```ruby
group :server do
  guard :shotgun do
    watch(/.+/) # watch *every* file in the directory
  end
end

guard 'livereload' do
  watch(%r{views/.+\.(erb|haml|slim)$})
  watch(%r{fooapp_rds.rb})
end
```

```
$ guard
14:00:14 - INFO - Guard is using TerminalTitle to send notifications.
14:00:14 - INFO - LiveReload is waiting for a browser to connect.
14:00:14 - INFO - Starting up Rack...
[2014-10-13 14:00:16] INFO  WEBrick 1.3.1
[2014-10-13 14:00:16] INFO  ruby 2.1.1 (2014-02-24) [x86_64-darwin12.0]
[2014-10-13 14:00:16] INFO  WEBrick::HTTPServer#start: pid=4927 port=9292

14:00:16 - INFO - Guard is now watching at '/Users/k2works/projects/github/aws_elasticbeanstalk_introduction/fooapp_rds'
```

_http://localhost:9292/_

### RDS対応セットアップ

_fooapp_rds/fooapp_rds.rb_から`set :database, {adapter: "sqlite3", database: "foo.sqlite3"}`を削除

_fooapp_rds/config/database.yml_作成

```
production:
  adapter: mysql2
  encoding: utf8
  database: <%= ENV['RDS_DB_NAME'] %>
  username: <%= ENV['RDS_USERNAME'] %>
  password: <%= ENV['RDS_PASSWORD'] %>
  host: <%= ENV['RDS_HOSTNAME'] %>
  port: <%= ENV['RDS_PORT'] %>

development:
  adapter: sqlite3
  database: db/development.sqlite3
  pool: 5
  timeout: 5000

test:
  adapter: sqlite3
  database: db/test.sqlite3
  pool: 5
  timeout: 5000
```

_fooapp_rds/Gemfile_編集

```ruby
gem "sqlite3", :group => [:development,:test]
gem "mysql", :group => :production
```

```bash
$ eb init
・・・
Create an RDS DB Instance? [y/n] (current value is "Yes"):
・・・
$ eb start
```

### デプロイコマンドの定義
_fooapp_rds/.ebextensions_

```
packages:
  yum:
    git: []
container_commands:
  bundle_install:
    command: bundle install --deployment
container_commands:
  01-bundle_install:
    command: bundle install --deployment
  02-db_migrate:
    command: bundle exec rake db:migrate
  03-chown:
    command: chown -R webapp:webapp ./
```

_fooapp_rds/config/initializers/.gitkeep_に追加

```bash
$ git add . && git commit -m "Add deploy setting"
$ git aws.push
```

その他DB設定は[RDS付きのBeanstalkを使う際の注意点](http://blog.serverworks.co.jp/tech/2013/03/12/rds_on_beanstalk/)参照

## <a name="5">Ruby での VPC の使用</a>
### VPC環境セットアップ
[AWS CloudFormation](http://aws.amazon.com/jp/cloudformation/)を使ってVPC環境をセットアップする。

_cloudformeer.template.fooapp_vpc.json_

### デプロイ環境構築
#### セットアップ
```bash
$ git init && git add -A && git commit -m "Initial commit"
$ eb init
```

#### AWSコンソールで環境セットアップ
![001](https://farm4.staticflickr.com/3952/15345959980_7ec9078d2d.jpg)

![002](https://farm4.staticflickr.com/3954/15345959930_ba13218111.jpg)

![003](https://farm4.staticflickr.com/3939/15345582417_fef0796d03.jpg)

![004](https://farm4.staticflickr.com/3953/15345448648_bee8d05313.jpg)

![005](https://farm6.staticflickr.com/5598/15345582507_693fc39e87.jpg)

![006](https://farm6.staticflickr.com/5597/15345448658_ac2504972d.jpg)

![007](https://farm6.staticflickr.com/5609/14910849794_2bd6a1df05.jpg)

![008](https://farm4.staticflickr.com/3938/15528895191_db40f01465.jpg)

![009](https://farm6.staticflickr.com/5598/15345448698_803a3cdfb3.jpg)

![010](https://farm6.staticflickr.com/5614/14911423733_c8ee53e66d.jpg)

![011](https://farm6.staticflickr.com/5602/15345959830_46234ca63e.jpg)

#### ローカルレポジトリとマッピング
```bash
$ eb branch
The current branch is "master".
Enter an AWS Elastic Beanstalk environment name (auto-generated value is "fooappvpc-master-env"): fooappVpc-env
Do you want to copy the settings from environment "production" for the new branch? [y/n]: y
Updated AWS Credential file at "/Users/k2works/.elasticbeanstalk/aws_credential_file".
$ eb start
Starting application "fooapp_vpc".
Some of your option settings are ignored because they don't apply to your environment type.
Environment "fooappVpc-env" already exists. Skipped creating.
Application is available at "production-fooappVpc-env.elasticbeanstalk.com".
```

### アプリケーションセットアップ
#### アプリケーション作成
```bash
$ rails new fooapp_vpc
$ cd fooapp_vpc
$ rails g scaffold article url:string title:string category:string published:date access:integer comments_count:integer losed:boolean
$ rake db:migrate
```

#### シークレットキーを環境変数に追加
```bash
$ rake secret
ea0f4840d6c3933cf1bab33ad45128a2c543fd1fac229411b5b81cdc7d71821b6c4f832613cd3bc6d8203f16e65521f41574fe446873f7c3956f17d9b72ef905
```
_fooapp_vpc/.elasticbeanstalk/optionsettings.production_

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
SECRET_KEY_BASE=ea0f4840d6c3933cf1bab33ad45128a2c543fd1fac229411b5b81cdc7d71821b6c4f832613cd3bc6d8203f16e65521f41574fe446873f7c3956f17d9b72ef905
・・・
```

#### データベースの設定

_fooapp_vpc/Gemfile_

```ruby
gem 'sqlite3', group: [:development,:test]
gem 'mysql2', group: :production
```

_fooapp_vpc/config/database.yml_

```yml
・・・
production:
  adapter: mysql2
  encoding: utf8
  database: <%= ENV['RDS_DB_NAME'] %>
  username: <%= ENV['RDS_USERNAME'] %>
  password: <%= ENV['RDS_PASSWORD'] %>
  host: <%= ENV['RDS_HOSTNAME'] %>
  port: <%= ENV['RDS_PORT'] %>
・・・
```

#### タイムゾーンの設定

_config/application.rb_

```
config.time_zone = 'Tokyo'
```

#### ルーティングの設定
_fooapp/config/routes.rb_

```ruby
root 'articles#index'
```

### アプリケーションデプロイ
```bash
$ git add -A && git commit -m "Application Setup"
$ eb update
$ eb push
```
### アプリケーション動作確認

![012](https://farm4.staticflickr.com/3941/14910849964_c61d06d23e.jpg)

![013](https://farm6.staticflickr.com/5616/14911423623_e89e9e0b4d.jpg)

### 後片付け
```bash
$ eb stop
$ eb delete
```

# 参照

* [AWS Elastic Beanstalk](http://docs.aws.amazon.com/ja_jp/elasticbeanstalk/latest/dg/Welcome.html)
* [Hazel](http://c7.github.io/hazel/)
* [is not checked out… bundle install does NOT fix help!](http://stackoverflow.com/questions/6648870/is-not-checked-out-bundle-install-does-not-fix-help)
* [RDS付きのBeanstalkを使う際の注意点](http://blog.serverworks.co.jp/tech/2013/03/12/rds_on_beanstalk/)
* [Sinatra ActiveRecord Extension](https://github.com/janko-m/sinatra-activerecord)
* [Rack::LiveReload](https://github.com/johnbintz/rack-livereload)
* [Guard::Shotgun](https://github.com/rchampourlier/guard-shotgun)
* [Guard::LiveReload](https://github.com/guard/guard-livereload)
* [Deploying a Git Branch to a Specific Environment](http://docs.aws.amazon.com/elasticbeanstalk/latest/dg/command-reference-branch-environment.html)
