# Integration testing
## Task

- [X] Read data sets scenarios
- [X] Build random fields
- [X] Send request in order scenarios
- [X] Json config to yaml
- [X] Save fields responses scenarios
- [X] Dynamic urls
- [ ] Metrics and safe fail 
- [ ] Vus in sub process
## Install
- download bin file 
- set path for bin file
` run ./intst


## run 

### yaml config 
```
    escript intst --data=example/register_data.yml --scenario=example/register_scenario.yml --vus=1

    intst --data=example/crcc_data.yml --scenario=example/crcc_scenario.yml --vus=1
```


### Json config
```
    escript intst --data=example/data_set.json --scenario=example/scenario.json --vus=1
```


## data file
data_case.yalm
```

global_vars:
  login_url: https://auth.com
  orders_url: https://orders.com
  cashin_url: https://cashin.com
config:
  iterations: 1
cases:
- global:
    user: email_testint_{[a-z]random}@gmail.com
    pass: "{[a-z]random}"
    country: CO
  register:
    referral_code: li_ko
  order_buy:
    stock: ECOPETROL
    price: 2500
  cashout:
    amount: 100

```


## scenario file 
Scemario.yalm
```
# request resgister
- type: register
  request:
    url: "{{url}}auth/register"
    method: POST
    headers: []
    params: {}
    body:
      email: "{{user}}"
      password: "{{pass}}"
      country: "{{country}}"
      referral_code: "{{country}}"
  checks:
    status: 201
    body:
      sk2: ''
```

```
intst data_set.json scenario.json -vus=1
escript intst data_set.json scenario.json vus=1
```

```
mix escript.build
escript intst --data=example/data_set.json --scenario=example/scenario.json --vus=1
escript intst --d=data_set.json --s=scenario.json --v=1
```

## Scenario examples

### Scenario create full user
- [X] register
- [X] login {sk2}
- [X] get_user_info {id}
- [X] bypass otps
- [ ] set data full 
- [ ] set images (*)
- [ ] bypass compliance (*)
- [ ] country check 1 / country check n ( obique)

```

```
### Scenario complete
- [ ] register
- [ ] login {sk2}
- [ ] get_user_info {id}
- [ ] bypass otps
- [ ] set data full 
- [ ] set images (*)
- [ ] bypass compliance (*)
- [ ] country check 1 / country check n ( obique )
- [ ] cashin + bypass
- [ ] order + bypass
- [ ] cashout + bypass
