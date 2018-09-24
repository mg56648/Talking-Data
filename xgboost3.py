import numpy as np
import pandas as pd
import math
import time
import xgboost as xgb
from sklearn.cross_validation import train_test_split

df = pd.read_csv('../input/talkingdata-adtracking-fraud-detection/train.csv', skiprows = 60000000, nrows = 50000000)
df.columns = ['ip', 'app', 'device', 'os', 'channel', 'click_time', 'attributed_time', 'is_attributed']
df1 = df[df['is_attributed'] == 1]
df2 = df[df['is_attributed'] == 0]
del df
df0 = pd.read_csv('../input/talkingdata-adtracking-fraud-detection/train.csv', skiprows = 160000000, nrows = 50000000)
df0.columns = ['ip', 'app', 'device', 'os', 'channel', 'click_time', 'attributed_time', 'is_attributed']
df3 = df0[df0['is_attributed'] == 1]
df4 = df0[df0['is_attributed'] == 0]
del df0
df1 = df1.ix[np.random.random_integers(0,len(df1),120000)]
df2 = df2.ix[np.random.random_integers(0,len(df2),240000)]
df3 = df3.ix[np.random.random_integers(0,len(df1),60000)]
df4 = df4.ix[np.random.random_integers(0,len(df2),120000)]
df5 = pd.read_csv('../input/talkingdata-adtracking-fraud-detection/train_sample.csv')
df6 = pd.read_csv('../input/train-extra-2/train_extra2.csv')
df = pd.concat([df1,df2,df3,df4,df5,df6])
df = df.drop_duplicates()

def PreProcessTime(df):
    df['click_time'] = pd.to_datetime(df['click_time']).dt.date
    df['click_time'] = df['click_time'].apply(lambda x: x.strftime('%Y%m%d')).astype(int) 
    return df
    
train = df
test = pd.read_csv("../input/talkingdata-adtracking-fraud-detection/test.csv")
train.columns = ['ip', 'app', 'device', 'os', 'channel', 'click_time', 'attributed_time', 'is_attributed']
train = train.drop(train.index[0])
train = PreProcessTime(train)
test = PreProcessTime(test)

y = train['is_attributed']
train.drop(['is_attributed', 'attributed_time'], axis=1, inplace=True)
store = pd.DataFrame()
store['click_id'] = test['click_id']
test.drop('click_id', axis=1, inplace=True)

params = {'eta': 0.1,'max_depth': 5,'subsample': 0.9,'colsample_bytree': 0.7,'colsample_bylevel':0.7,'min_child_weight':50,
          'alpha':4,'objective': 'binary:logistic','eval_metric': 'auc','random_state': 238,'scale_pos_weight': 150,
          'silent': True}
          
x1, x2, y1, y2 = train_test_split(train, y, test_size=0.1, random_state=238)

totallist = [(xgb.DMatrix(x1, y1), 'train'), (xgb.DMatrix(x2, y2), 'valid')]
model = xgb.train(params, xgb.DMatrix(x1, y1), 400, totallist, maximize=True, verbose_eval=10)

store['is_attributed'] = model.predict(xgb.DMatrix(test), ntree_limit=model.best_ntree_limit)

store.to_csv('xgb1_withtrain5.csv',index=False) 
