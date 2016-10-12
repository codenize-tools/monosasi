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

rule "cron" do
  state "ENABLED"
  description "my cron"
  schedule_expression "cron(0 17 ? * MON-FRI *)"
  target "xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx" do
    arn "arn:aws:lambda:ap-northeast-1:123456789012:function:hello-world"
    input_path '$.detail'
  end
  target "yyyyyyyy-yyyy-yyyy-yyyy-yyyyyyyyyyyy" do
    arn "arn:aws:lambda:ap-northeast-1:123456789012:function:my-func"
  end
end

rule "ssm role" do
  state "ENABLED"
  event_pattern do
    {"detail-type"=>
      ["EC2 Command Invocation Status-change Notification",
       "EC2 Command Status-change Notification"],
     "source"=>["aws.ssm"]}
  end
  target "zzzzzzzz-zzzz-zzzz-zzzz-zzzzzzzzzzzz" do
    arn "arn:aws:lambda:ap-northeast-1:123456789012:function:trigger-func"
    input '{"foo": "bar"}'
  end
end
```

## Similar tools
* [Codenize.tools](http://codenize.tools/)
