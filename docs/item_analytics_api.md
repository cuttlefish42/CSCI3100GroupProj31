# Item Analytics API

## `GET /items/:id/analytics`

Returns hourly snapshots of an item's view and like counts over time.

**Auth:** Required — must be the item's seller.

### Query Parameters

| Param | Type             | Required | Default    | Description        |
|-------|------------------|----------|------------|--------------------|
| `from`| ISO 8601 datetime| No       | 7 days ago | Start of time range|
| `to`  | ISO 8601 datetime| No       | Now        | End of time range  |

### Example Request

```
GET /items/3/analytics?from=2026-04-05&to=2026-04-12
```

### Response `200 OK`

```json
[
  {
    "recorded_at": "2026-04-05T00:00:00+08:00",
    "views_count": 12,
    "likes_count": 3
  },
  {
    "recorded_at": "2026-04-05T01:00:00+08:00",
    "views_count": 15,
    "likes_count": 3
  }
]
```

- Array of snapshot objects ordered by `recorded_at` ascending
- `views_count` / `likes_count` are cumulative totals at that point in time (not deltas)
- One entry per hour interval

### Error Responses

| Status                  | Condition                                |
|-------------------------|------------------------------------------|
| `302` → `/sessions/new` | Not authenticated                        |
| `302` → `/items`        | Authenticated but not the item's seller  |
