# Integration testing


## Task

- [X] Read data sets scenarios
- [X] Build random fields
- [X] Send request in order scenarios
- [ ] Json config to yaml
- [ ] Save fields responses scenarios
- [ ] Metrics and safe fail 
- [ ] Vus in sub process



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
- [ ] register
- [ ] login {sk2}
- [ ] get_user_info {id}
- [ ] bypass otps
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
