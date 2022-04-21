USE [XDatabase]
GO
/****** Object:  StoredProcedure [etl].[UpdateProductMaster]    Script Date: 4/21/2022 4:19:13 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO



ALTER PROC [etl].[UpdateProductMaster]
AS


DROP TABLE IF EXISTS #Keywords

SELECT *
INTO #Keywords
FROM (
SELECT '%Picnic%' AS Keyword, 'Picnic Table' AS Parent, 1 as [RowRank] UNION
SELECT '%Bike Rack%', 'Bike Rack', 2 UNION
SELECT '%Paper Towel Bracket%', 'Paper Towel Bracket', 3 UNION
SELECT '%Grill%', 'Grill', 4 UNION
SELECT '%Fire Ring%', 'Grill', 5 UNION
SELECT '%Tree Grate%', 'Tree Grate', 6 UNION
--... more keywords 
) A


WHILE (SELECT COUNT(*) FROM #Keywords) > 0
BEGIN

DECLARE @SQL nvarchar(1000)
DECLARE @Keyword nvarchar(50) = (SELECT TOP 1 Keyword FROM #Keywords ORDER BY RowRank)
DECLARE @Parent nvarchar(50) = (SELECT TOP 1 Parent FROM #Keywords ORDER BY RowRank)



SET @SQL =
'UPDATE stage.ProductMaster 
SET ProductCategory = '''
+
@Parent
+
''''
+
'
WHERE LineDescription like ''' + @Keyword + ''''
+ 
' 
AND ProductCategory IS NULL
'

PRINT @SQL
EXEC (@SQL)

DELETE FROM #Keywords
WHERE Keyword = @Keyword

END;


UPDATE I 
SET 
	ProductCategory = 'Other'
FROM stage.ProductMaster I 
WHERE ProductCategory IS NULL


/* ================================================ Second Category ===================== */


DROP TABLE IF EXISTS #KeywordsConsolidated

SELECT *
INTO #KeywordsConsolidated
FROM (
SELECT '%Picnic%' AS Keyword, 'Picnic Table' AS Parent, 1 as [RowRank] UNION
SELECT '%Umbrella%', 'Umbrella', 2 UNION
SELECT '% Table%', 'Table', 3 UNION
SELECT '%Bench%', 'Bench', 4 UNION
SELECT '%Chair%', 'Chair', 5 UNION
SELECT '%Receptacle%', 'Receptacle', 6 
) A


WHILE (SELECT COUNT(*) FROM #KeywordsConsolidated) > 0
BEGIN

DECLARE @SQLConsolidated nvarchar(1000)
DECLARE @KeywordConsolidated nvarchar(50) = (SELECT TOP 1 Keyword FROM #KeywordsConsolidated ORDER BY RowRank)
DECLARE @ParentConsolidated nvarchar(50) = (SELECT TOP 1 Parent FROM #KeywordsConsolidated ORDER BY RowRank)



SET @SQLConsolidated =
'UPDATE stage.ProductMaster 
SET ConsolidatProductCtg = '''
+
@ParentConsolidated
+
''''
+
'
WHERE LineDescription like ''' + @KeywordConsolidated + ''''
+ 
' 
AND ConsolidatProductCtg IS NULL
'

PRINT @SQLConsolidated

EXEC (@SQLConsolidated)

DELETE FROM #KeywordsConsolidated
WHERE Keyword = @KeywordConsolidated

END;