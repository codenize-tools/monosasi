# Monosasi

Monosasi is a tool to manage [Cloudwatch Events](https://docs.aws.amazon.com/AmazonCloudWatch/latest/events/WhatIsCloudWatchEvents.html) rules.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'monosasi'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install monosasi

## Usage

```sh
export AWS_ACCESS_KEY_ID='...'
export AWS_SECRET_ACCESS_KEY='...'

# export rules to `Rulefile`
monosasi -e -o Rulefile

vi Rulefile

# apply `Rulefile` to Cloudwatch Events
monosasi -a --dry-run
monosasi -a
```

## Help

```
Usage: monosasi [options]
    -k, --access-key ACCESS_KEY
    -s, --secret-key SECRET_KEY
    -r, --region REGION
        --profile PROFILE
        --credentials-path PATH
    -a, --apply
    -f, --file FILE
        --dry-run
    -e, --export
    -o, --output FILE
        --split
        --target REGEXP
        --no-color
        --debug
```

## Rulefile example

```ruby
require 'other/rulefile'

bucket "foo-bucket" do
  {"Version"=>"2012-10-17",
   "Id"=>"AWSConsole-AccessLogs-Policy-XXX",
   "Statement"=>
    [{"Sid"=>"AWSConsoleStmt-XXX",
      "Effect"=>"Allow",
      "Principal"=>{"AWS"=>"arn:aws:iam::XXX:root"},
      "Action"=>"s3:PutObject",
      "Resource"=>
       "arn:aws:s3:::foo-bucket/AWSLogs/XXX/*"}]}
end

bucket "bar-bucket" do
  {"Version"=>"2012-10-17",
   "Statement"=>
    [{"Sid"=>"AddPerm",
      "Effect"=>"Allow",
      "Principal"=>"*",
      "Action"=>"s3:GetObject",
      "Resource"=>"arn:aws:s3:::bar-bucket/*"}]}
end
```

## Similar tools
* [Codenize.tools](http://codenize.tools/)
