WITH sessions_info AS (                                                 -- Subquery 1. Collecting session data
  SELECT
    user_pseudo_id,

    (SELECT value.int_value                                              -- Extract ga_session_id from the nested event_params array
    FROM UNNEST(event_params)
    WHERE key = 'ga_session_id') as session_id,

    CONCAT(                                                              -- Create a unique user session identifier (user + session_id) 
      user_pseudo_id,
      CAST((SELECT value.int_value
            FROM UNNEST(event_params)
            WHERE key = 'ga_session_id') AS STRING)
    ) as user_session_id,

    DATE(TIMESTAMP_MICROS(event_timestamp)) as session_date,              -- Convert the timestamp from microseconds to a standard date format 

    geo.country as country,

    device.category as device_category,                                   -- Add dimensions (slices) for analysis
    device.language as device_language,
    device.operating_system as operating_system,

    traffic_source.source as source,
    traffic_source.medium as medium,
    traffic_source.name as campaign

  FROM `bigquery-public-data.ga4_obfuscated_sample_ecommerce.events_*`
  WHERE event_name = 'session_start'                                      -- Select only session start events 
    AND _TABLE_SUFFIX BETWEEN '20201101' AND '20210131'                   -- Limit the data to the required date range 
),

landing_page AS (                                                         -- Subquery 2. Defining the landing page
  SELECT
    user_session_id,
    IFNULL(                                                               -- Remove the domain and parameters. Replace null values with an empty string
      NULLIF(
        REGEXP_REPLACE(
          REGEXP_EXTRACT(                                                  
            page_location,                
            r'^https?://[^/]+(/[^?]*)' 
          ),
          r'^/',
          ''
        ),
        ''
      ),
    ''
    ) AS landing_page_location

  FROM (
    SELECT
      CONCAT(
        user_pseudo_id,
        CAST((SELECT value.int_value
              FROM UNNEST(event_params)
              WHERE key = 'ga_session_id') AS STRING)
      ) as user_session_id,

      (SELECT value.string_value
       FROM UNNEST(event_params)
       WHERE key = 'page_location') as page_location,

      ROW_NUMBER() OVER (
         PARTITION BY CONCAT(
           user_pseudo_id,
           CAST((SELECT value.int_value
              FROM UNNEST(event_params)
              WHERE key = 'ga_session_id') AS STRING)
         )
         ORDER BY event_timestamp
      ) as rn

    FROM `bigquery-public-data.ga4_obfuscated_sample_ecommerce.events_*`
    WHERE event_name = 'page_view'                                      
    AND _TABLE_SUFFIX BETWEEN '20201101' AND '20210131'
  )
  WHERE rn = 1
),

events AS (                                                                -- Subquery 3. Collecting funnel events
  SELECT
    TIMESTAMP_MICROS(event_timestamp) as event_timestamp,                  -- Convert event_timestamp to TIMESTAMP
    event_name,

    CONCAT(                                                                -- Create the same user_session_id to join tables
      user_pseudo_id,
      CAST((SELECT value.int_value
            FROM UNNEST(event_params)
            WHERE key = 'ga_session_id') AS STRING)
    ) as user_session_id              

  FROM `bigquery-public-data.ga4_obfuscated_sample_ecommerce.events_*` 
  WHERE event_name IN(                                                      -- Select only funnel steps
    'session_start',
    'view_item',
    'add_to_cart',
    'begin_checkout',
    'add_shipping_info',
    'add_payment_info',
    'purchase'
  )
  AND _TABLE_SUFFIX BETWEEN '20201101' AND '20210131'
)

SELECT                                                                      -- Main query
  s.user_pseudo_id,
  s.session_id,
  s.user_session_id,
  s.session_date,
  lp.landing_page_location,
  s.country,
  s.device_category,
  s.device_language,
  s.operating_system,
  s.source,
  s.medium,
  s.campaign,
  e.event_timestamp,                                                         
  e.event_name                                                                                                                   

FROM sessions_info s
LEFT JOIN events e
  ON s.user_session_id = e.user_session_id
LEFT JOIN landing_page lp
  ON s.user_session_id = lp.user_session_id
  
