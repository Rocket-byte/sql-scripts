-- SQL Query for Weekly Data Analysis of Users, Comments, and File Stacks
-- Author: Ruslana Kruk

WITH 
users_data AS (
    -- Subquery for new users data by week
    SELECT 
        TRUNC(s.ext_id_created_at, 'IW') AS Date_users,
        COUNT(1) AS Users_new
    FROM 
        users s
    WHERE 
        s.ext_id_created_at IS NOT NULL
    GROUP BY 
        TRUNC(s.ext_id_created_at, 'IW')
),
Commens_Data AS (
    -- Subquery for comments data by week
    SELECT 
        TRUNC(c.created_at, 'IW') AS Comment_Date,
        COUNT(DISTINCT c.user_id) AS Comments_users,
        COUNT(DISTINCT DECODE(s.PAID_TYPE, 0, c.user_id)) AS Comments_users_Free,
        COUNT(DISTINCT DECODE(s.PAID_TYPE, 1, c.user_id)) AS Comments_users_Paid,
        COUNT(DISTINCT c.id) AS Comments_Per_day,
        COUNT(DISTINCT DECODE(s.PAID_TYPE, 0, c.id)) AS Comments_Per_day_free,
        COUNT(DISTINCT DECODE(s.PAID_TYPE, 1, c.id)) AS Comments_Per_day_paid
    FROM 
        file_stack_comments c
    JOIN 
        file_stacks s ON s.id = c.file_stack_id AND s.paid_type >= 0
    WHERE 
        c.user_id NOT IN (SELECT u.id FROM users u WHERE u.creator IS NOT NULL)
    GROUP BY 
        TRUNC(c.created_at, 'IW')
),
fs_data AS (
    -- Subquery for file stacks data by week
    SELECT 
        TRUNC(s.created_at, 'IW') Date_date,
        COUNT(DISTINCT s.user_id) AS Creators_All,
        COUNT(DISTINCT DECODE(PAID_TYPE, 0, s.user_id)) AS Creators_Free,
        COUNT(DISTINCT DECODE(PAID_TYPE, 1, s.user_id)) AS Creators_Paid,
        COUNT(DISTINCT s.id) AS Posts_All,
        COUNT(DISTINCT DECODE(PAID_TYPE, 0, s.id)) AS Posts_Free,
        COUNT(DISTINCT DECODE(PAID_TYPE, 1, s.id)) AS Posts_Paid,
        SUM(s.views_count) AS View_All,
        SUM(DECODE(PAID_TYPE, 0, s.views_count)) AS View_Free,
        SUM(DECODE(PAID_TYPE, 1, s.views_count)) AS View_Paid,
        TRUNC(SUM((s.price / 100) * s.views_count)) AS Total_Expense
    FROM 
        file_stacks s
    WHERE 
        1 = 1 -- Placeholder for additional conditions
        AND s.price IS NOT NULL
        AND s.created_at >= TO_DATE('01.01.2022', 'DD.MM.YYYY')
    GROUP BY 
        TRUNC(s.created_at, 'IW')
)

-- Main query to combine and present the aggregated data
SELECT 
    DATE_DATE,
    CREATORS_ALL,
    CREATORS_FREE,
    CREATORS_PAID,
    POSTS_ALL,
    POSTS_FREE,
    POSTS_PAID,
    VIEW_ALL,
    VIEW_FREE,
    VIEW_PAID,
    TOTAL_EXPENSE,
    USERS_NEW,
    COMMENTS_USERS,
    COMMENTS_USERS_FREE,
    COMMENTS_USERS_PAID,
    COMMENTS_PER_DAY,
    COMMENTS_PER_DAY_FREE,
    COMMENTS_PER_DAY_PAID
FROM 
    fs_data fd
LEFT JOIN 
    users_data us ON us.Date_users = fd.Date_date
LEFT JOIN 
    Commens_Data cs ON cs.Comment_Date = fd.Date_date
ORDER BY 
    Date_date DESC;
