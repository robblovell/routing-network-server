Redis = require('ioredis')
redis = new Redis('redis://127.0.0.1:6379/1')
redis.flushall()