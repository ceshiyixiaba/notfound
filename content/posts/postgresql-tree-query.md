+++
title = "Postgresql 树形结构查询"
author = ["likui"]
date = 2021-05-15T16:00:00+08:00
lastmod = 2021-05-15T16:05:19+08:00
tags = ["database"]
draft = false
+++

## Postgresql 树形结构查询 {#postgresql-树形结构查询}

-   PostgreSQL 13.2


### 创建表 {#创建表}

```sql
CREATE TABLE tree (
  id INTEGER,
  parent_id INTEGER,
  name TEXT
);
```


### 添加数据 {#添加数据}

```sql
INSERT INTO tree VALUES(1, NULL, '中国');

INSERT INTO tree VALUES(2, 1, '四川');
INSERT INTO tree VALUES(3, 1, '云南');

INSERT INTO tree VALUES(4, 2, '成都');
INSERT INTO tree VALUES(5, 2, '绵阳');
INSERT INTO tree VALUES(6, 3, '昆明');

INSERT INTO tree VALUES(7, 4, '武侯区');
```


### 查询字节点 {#查询字节点}

```sql
WITH RECURSIVE cte(id, name, traversal_ids, traversal_names, cycle) AS (
  VALUES(2, '四川', ARRAY[2], ARRAY['四川'], false)
  UNION ALL
  SELECT tree.id, tree.name, cte.traversal_ids || tree.id, cte.traversal_names || tree.name, tree.id = ANY(cte.traversal_ids)
  FROM tree, cte
  WHERE tree.parent_id = cte.id AND NOT cycle
) SELECT id, name, traversal_ids, traversal_names FROM cte;
```


### 查询父节点 {#查询父节点}

```sql
WITH RECURSIVE cte(id, parent_id, traversal_ids, traversal_names, cycle) AS (
  VALUES(6, 4, ARRAY[6], ARRAY['武侯区'], false)
  UNION ALL
  SELECT tree.ID, tree.parent_id, cte.traversal_ids || tree.id, cte.traversal_names || tree.name, tree.id = ANY(cte.traversal_ids)
  FROM tree, cte
  WHERE tree.id = cte.parent_id AND NOT cycle
) SELECT id, parent_id, traversal_ids, traversal_names FROM cte;
```


### 参考 {#参考}

-   [PostgreSQL\_树形结构的递归查询](https://juejin.cn/post/6844904061414670350)
