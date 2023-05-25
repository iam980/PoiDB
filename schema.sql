USE [master]
GO
ALTER DATABASE [PoiDB] SET COMPATIBILITY_LEVEL = 140
GO
IF (1 = FULLTEXTSERVICEPROPERTY('IsFullTextInstalled'))
begin
EXEC [PoiDB].[dbo].[sp_fulltext_database] @action = 'enable'
end
GO
ALTER DATABASE [PoiDB] SET ANSI_NULL_DEFAULT OFF 
GO
ALTER DATABASE [PoiDB] SET ANSI_NULLS OFF 
GO
ALTER DATABASE [PoiDB] SET ANSI_PADDING OFF 
GO
ALTER DATABASE [PoiDB] SET ANSI_WARNINGS OFF 
GO
ALTER DATABASE [PoiDB] SET ARITHABORT OFF 
GO
ALTER DATABASE [PoiDB] SET AUTO_CLOSE OFF 
GO
ALTER DATABASE [PoiDB] SET AUTO_SHRINK OFF 
GO
ALTER DATABASE [PoiDB] SET AUTO_UPDATE_STATISTICS ON 
GO
ALTER DATABASE [PoiDB] SET CURSOR_CLOSE_ON_COMMIT OFF 
GO
ALTER DATABASE [PoiDB] SET CURSOR_DEFAULT  GLOBAL 
GO
ALTER DATABASE [PoiDB] SET CONCAT_NULL_YIELDS_NULL OFF 
GO
ALTER DATABASE [PoiDB] SET NUMERIC_ROUNDABORT OFF 
GO
ALTER DATABASE [PoiDB] SET QUOTED_IDENTIFIER OFF 
GO
ALTER DATABASE [PoiDB] SET RECURSIVE_TRIGGERS OFF 
GO
ALTER DATABASE [PoiDB] SET  DISABLE_BROKER 
GO
ALTER DATABASE [PoiDB] SET AUTO_UPDATE_STATISTICS_ASYNC OFF 
GO
ALTER DATABASE [PoiDB] SET DATE_CORRELATION_OPTIMIZATION OFF 
GO
ALTER DATABASE [PoiDB] SET TRUSTWORTHY OFF 
GO
ALTER DATABASE [PoiDB] SET ALLOW_SNAPSHOT_ISOLATION OFF 
GO
ALTER DATABASE [PoiDB] SET PARAMETERIZATION SIMPLE 
GO
ALTER DATABASE [PoiDB] SET READ_COMMITTED_SNAPSHOT OFF 
GO
ALTER DATABASE [PoiDB] SET HONOR_BROKER_PRIORITY OFF 
GO
ALTER DATABASE [PoiDB] SET RECOVERY SIMPLE 
GO
ALTER DATABASE [PoiDB] SET  MULTI_USER 
GO
ALTER DATABASE [PoiDB] SET PAGE_VERIFY CHECKSUM  
GO
ALTER DATABASE [PoiDB] SET DB_CHAINING OFF 
GO
ALTER DATABASE [PoiDB] SET FILESTREAM( NON_TRANSACTED_ACCESS = OFF ) 
GO
ALTER DATABASE [PoiDB] SET TARGET_RECOVERY_TIME = 60 SECONDS 
GO
ALTER DATABASE [PoiDB] SET DELAYED_DURABILITY = DISABLED 
GO
ALTER DATABASE [PoiDB] SET ACCELERATED_DATABASE_RECOVERY = OFF  
GO
EXEC sys.sp_db_vardecimal_storage_format N'PoiDB', N'ON'
GO
ALTER DATABASE [PoiDB] SET QUERY_STORE = OFF
GO
USE [PoiDB]
GO
/****** Object:  UserDefinedFunction [dbo].[geometry2json]    Script Date: 5/25/2023 9:46:54 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE FUNCTION [dbo].[geometry2json]( @geo geometry)
RETURNS nvarchar(MAX) AS
BEGIN
RETURN (
'{' +
(CASE @geo.STGeometryType()
WHEN 'POINT' THEN
'"type": "Point","coordinates":' +
REPLACE(REPLACE(REPLACE(REPLACE(@geo.ToString(),'POINT ',''),'(','['),')',']'),' ',',')
WHEN 'POLYGON' THEN
'"type": "Polygon","coordinates":' +
'[' + REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(@geo.ToString(),'POLYGON ',''),'(','['),')',']'),'], ',']],['),', ','],['),' ',',') + ']'
WHEN 'MULTIPOLYGON' THEN
'"type": "MultiPolygon","coordinates":' +
'[' + REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(@geo.ToString(),'MULTIPOLYGON ',''),'(','['),')',']'),'], ',']],['),', ','],['),' ',',') + ']'
WHEN 'MULTIPOINT' THEN
'"type": "MultiPoint","coordinates":' +
'[' + REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(@geo.ToString(),'MULTIPOINT ',''),'(','['),')',']'),'], ',']],['),', ','],['),' ',',') + ']'
WHEN 'LINESTRING' THEN
'"type": "LineString","coordinates":' +
'[' + REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(@geo.ToString(),'LINESTRING ',''),'(','['),')',']'),'], ',']],['),', ','],['),' ',',') + ']'
ELSE NULL
END)
+'}')
END
GO
/****** Object:  Table [dbo].[Tags]    Script Date: 5/25/2023 9:46:54 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Tags](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[Val] [varchar](100) NOT NULL,
 CONSTRAINT [PK_Tags] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[LocationTags]    Script Date: 5/25/2023 9:46:54 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[LocationTags](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[LocationID] [varchar](19) NOT NULL,
	[TagID] [int] NOT NULL,
 CONSTRAINT [PK_LocationTags] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  View [dbo].[vwTags]    Script Date: 5/25/2023 9:46:54 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO



CREATE VIEW [dbo].[vwTags]
as
	SELECT 
		lt.LocationID
		, t.Val as TagName
	FROM 
		LocationTags AS lt(NOLOCK) LEFT JOIN Tags as t(NOLOCK) 
			ON lt.TagID = t.ID

	--FOR JSON AUTO
	--order by 1
GO
/****** Object:  Table [dbo].[Locations]    Script Date: 5/25/2023 9:46:54 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Locations](
	[id] [varchar](19) NOT NULL,
	[parent_id] [varchar](19) NULL,
	[location_name] [nvarchar](max) NULL,
	[operation_hours] [nvarchar](max) NULL,
	[polygon_wkt] [nvarchar](max) NULL,
	[CityCodeID] [int] NOT NULL,
	[BrandID] [int] NULL,
	[CategoryID] [int] NULL,
	[location_pt] [geography] NULL,
 CONSTRAINT [PK_phoenix] PRIMARY KEY CLUSTERED 
(
	[id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
/****** Object:  Table [dbo].[Categories]    Script Date: 5/25/2023 9:46:54 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Categories](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[ParentID] [int] NULL,
	[Val] [varchar](100) NOT NULL,
 CONSTRAINT [PK_Categories_1] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  View [dbo].[vwCategories]    Script Date: 5/25/2023 9:46:54 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE VIEW [dbo].[vwCategories]
as
	select 
		b.ID
		, a.Val as TopCat
		, b.Val as SubCat 
	from 
		Categories as a(NOLOCK) left join Categories as b(NOLOCK) on a.ID = b.ParentID 
	WHERE a.ParentID IS NULL
		and b.ParentID IS not NULL

	UNION 

	select 
		a.ID
		, a.Val as TopCat
		, NULL as SubCat 
	from 
		Categories as a(NOLOCK) 
	WHERE a.ParentID IS NULL

	--order by 1
GO
/****** Object:  Table [dbo].[Regions]    Script Date: 5/25/2023 9:46:54 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Regions](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[CountryID] [int] NULL,
	[Val] [nvarchar](100) NOT NULL,
 CONSTRAINT [PK_States] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[Countries]    Script Date: 5/25/2023 9:46:54 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Countries](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[Val] [varchar](2) NOT NULL,
 CONSTRAINT [PK_CountryCodes] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[Codes]    Script Date: 5/25/2023 9:46:54 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Codes](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[RegionID] [int] NULL,
	[Val] [varchar](10) NOT NULL,
 CONSTRAINT [PK_Codes] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[Cities]    Script Date: 5/25/2023 9:46:54 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Cities](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[Val] [nvarchar](100) NOT NULL,
 CONSTRAINT [PK_StateCities] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[CityCodes]    Script Date: 5/25/2023 9:46:54 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[CityCodes](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[CodeID] [int] NOT NULL,
	[CityID] [int] NOT NULL,
 CONSTRAINT [PK_CityCodes] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  View [dbo].[vwCityCodes]    Script Date: 5/25/2023 9:46:54 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO



CREATE VIEW [dbo].[vwCityCodes]
as
	select 
		cc.ID
		, cou.Val as Country
		, r.Val as Region
		, ci.Val as City
		, cod.Val as PostalCode
	from 
		CityCodes as cc(NOLOCK) left join Codes as cod(NOLOCK) on cc.CodeID = cod.ID
								left join Cities as ci(NOLOCK) on cc.CityID = ci.ID
								left join Regions as r(NOLOCK) on cod.RegionID = r.ID
								left join Countries as cou(NOLOCK) on r.CountryID = cou.ID
GO
/****** Object:  View [dbo].[vwLocations]    Script Date: 5/25/2023 9:46:54 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO



CREATE VIEW [dbo].[vwLocations]
AS

	SELECT 
		'Feature' AS FeatureString

		, d.id 
		, d.parent_id

		, cc.Country 
		, cc.Region 
		, cc.City 

		, d.location_pt
		
		, cats.TopCat 
		, cats.SubCat 
		
		, d.location_name 
		
		, cc.PostalCode 
		, d.operation_hours 
		
		, d.polygon_wkt
		--, dbo.geometry2json( geometry::STGeomFromText(d.polygon_wkt, 4326) ) as [pol_geometry]	
		, JSON_QUERY( dbo.geometry2json( geometry::STGeomFromText(d.polygon_wkt, 4326) ) ) as [geometry]	

		, REPLACE( 
				REPLACE( 
					(SELECT TagName FROM [vwTags] as b where b.LocationID = d.ID  FOR JSON AUTO)
					, '{"TagName":'
					,'' 
				)
			, '"}'
			,'"' 
		) AS TagNames

	FROM 
		Locations AS d(NOLOCK) left join [dbo].[vwCityCodes] as cc(NOLOCK)
				on d.CityCodeID = cc.ID
								left join [dbo].[vwCategories] as cats(NOLOCK)
				on d.CategoryID = cats.ID

GO
/****** Object:  Table [dbo].[Brands]    Script Date: 5/25/2023 9:46:54 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Brands](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[Val] [nvarchar](100) NOT NULL,
 CONSTRAINT [PK_Brands] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
SET ANSI_PADDING ON
GO
/****** Object:  Index [UQ_Val]    Script Date: 5/25/2023 9:46:54 PM ******/
CREATE UNIQUE NONCLUSTERED INDEX [UQ_Val] ON [dbo].[Cities]
(
	[Val] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
/****** Object:  Index [IDX_CodeID_CityID]    Script Date: 5/25/2023 9:46:54 PM ******/
CREATE NONCLUSTERED INDEX [IDX_CodeID_CityID] ON [dbo].[CityCodes]
(
	[CodeID] ASC,
	[CityID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
/****** Object:  Index [IDX_RegionID]    Script Date: 5/25/2023 9:46:54 PM ******/
CREATE NONCLUSTERED INDEX [IDX_RegionID] ON [dbo].[Codes]
(
	[RegionID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
SET ANSI_PADDING ON
GO
/****** Object:  Index [UQ_Val]    Script Date: 5/25/2023 9:46:54 PM ******/
CREATE UNIQUE NONCLUSTERED INDEX [UQ_Val] ON [dbo].[Countries]
(
	[Val] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
/****** Object:  Index [IDX_Locations_COLs_CityCodeID]    Script Date: 5/25/2023 9:46:54 PM ******/
CREATE NONCLUSTERED INDEX [IDX_Locations_COLs_CityCodeID] ON [dbo].[Locations]
(
	[CityCodeID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
SET ANSI_PADDING ON
GO
/****** Object:  Index [IDX_LocationTags_COLs_LocationID]    Script Date: 5/25/2023 9:46:54 PM ******/
CREATE NONCLUSTERED INDEX [IDX_LocationTags_COLs_LocationID] ON [dbo].[LocationTags]
(
	[LocationID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
SET ANSI_PADDING ON
GO
/****** Object:  Index [UQ_Val]    Script Date: 5/25/2023 9:46:54 PM ******/
CREATE UNIQUE NONCLUSTERED INDEX [UQ_Val] ON [dbo].[Regions]
(
	[Val] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
ALTER TABLE [dbo].[Codes]  WITH CHECK ADD  CONSTRAINT [FK_Codes_Regions] FOREIGN KEY([RegionID])
REFERENCES [dbo].[Regions] ([ID])
GO
ALTER TABLE [dbo].[Codes] CHECK CONSTRAINT [FK_Codes_Regions]
GO
ALTER TABLE [dbo].[Regions]  WITH CHECK ADD  CONSTRAINT [FK_Regions_Countries] FOREIGN KEY([CountryID])
REFERENCES [dbo].[Countries] ([ID])
GO
ALTER TABLE [dbo].[Regions] CHECK CONSTRAINT [FK_Regions_Countries]
GO
/****** Object:  StoredProcedure [dbo].[spFindPOIs]    Script Date: 5/25/2023 9:46:54 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[spFindPOIs] @json nvarchar(max)
AS
BEGIN
    SET NOCOUNT ON

	DECLARE @OutputJson NVARCHAR(MAX)

	-- Get provided param values

    DECLARE @Country varchar(2),
            @Region nvarchar(max),
            @City nvarchar(max),

            @Lat float,
            @Long float,
            @Radius int,

            @PolygonWKT nvarchar(max),

            @POI_Category nvarchar(max),
            @POI_Name nvarchar(max)

    SELECT @Country = country,
           @Region = region,
           @City = city,

           @Lat = lat,
           @Long = long,
           @Radius = radius,

           @PolygonWKT = polygon,

           @POI_Category = poi_category,
           @POI_Name = poi_name
    FROM
        OPENJSON(@json)
        WITH
        (
            country varchar(2),
            region nvarchar(max),
            city nvarchar(max),

            [lat] float '$.location.lat',
            [long] float '$.location.lon',
            [radius] int '$.location.radius',

            polygon nvarchar(max),

            poi_category nvarchar(max),
            poi_name nvarchar(max)
        )


	-- Construct where clause

    declare @whereStr nvarchar(max) = ''

    IF isnull(@Country, '') <> ''
        SET @whereStr = @whereStr + ' AND Country = @Country_loc'

    IF isnull(@Region, '') <> ''
        SET @whereStr = @whereStr + ' AND Region = @Region_loc'

    IF isnull(@City, '') <> ''
        SET @whereStr = @whereStr + ' AND City = @City_loc'

    IF isnull(@POI_Category, '') <> ''
        SET @whereStr = @whereStr + ' AND TopCat like N'''' + @POI_Category_loc + ''%'''
		
    IF isnull(@POI_Name, '') <> ''
        SET @whereStr = @whereStr + ' AND location_name like N'''' + @POI_Name_loc + ''%'''

    IF isnull(@Lat, '') <> '' and isnull(@Long, '') <> '' and isnull(@Radius, '') <> ''
        SET @whereStr = @whereStr + ' AND location_pt.STDistance(geography::STPointFromText(''POINT ('' + @Long_loc + '' '' + @Lat_loc + '')'', 4326)) < @Radius_loc'

	IF isnull(@PolygonWKT, '') <> ''
        SET @whereStr = @whereStr + ' AND geometry::STGeomFromText(d.polygon_wkt, 4326).STIntersects(geometry::STGeomFromText(@PolygonWKT_loc, 4326)) = 1'


	-- Construct Sql Statement

    declare @SqlCmd nvarchar(max) = N'
			SELECT

				  d.FeatureString AS type

				, id as [properties.id]
				, parent_id as [properties.parentid]

				, Country as [properties.country]
				, Region as [properties.region]
				, City as [properties.city]

				, location_pt.Lat  as [properties.latitude]
				, location_pt.Long as [properties.longitude]

				, TopCat as [properties.category]
				, SubCat as [properties.subcategory]
	
				, location_name as [properties.locationname]

				, PostalCode as [properties.postalcode]
				, operation_hours as [properties.operationhours]

				--, d.polygon_wkt
				, d.[geometry]

			FROM 
				[dbo].[vwLocations] as d
			'

	-- If no search criteria was provided, set defaults (200 meters)

    IF @whereStr = '' 
    BEGIN
        SET @Lat = '42.268497467041016'
        SET @Long = '-122.80997467041016'
        SET @Radius = 200

        SET @whereStr = @whereStr
			+ ' AND location_pt.STDistance(geography::STPointFromText(''POINT ('' + @Long_loc + '' '' + @Lat_loc + '')'', 4326)) < @radius_loc'
    END

	-- Remove first " AND "
    SET @whereStr = SUBSTRING(@whereStr, 5, LEN(@whereStr)) 

    SET @SqlCmd =  @SqlCmd + ' WHERE' + @whereStr + ' FOR JSON PATH'	
	SET @SqlCmd = 'SELECT @OutputJson_Loc = (' + @SqlCmd + ')'

	print @SqlCmd

    DECLARE @Params NVARCHAR(MAX) = N'
			@Country_loc varchar(2)
			, @Region_loc nvarchar(max)
			, @City_loc nvarchar(max)
			, @PolygonWKT_loc nvarchar(max)
			, @POI_Category_loc nvarchar(max)
			, @POI_Name_loc nvarchar(max)
			, @Lat_loc nvarchar(max)
			, @Long_loc nvarchar(max)
			, @Radius_loc int

			, @OutputJson_Loc NVARCHAR(MAX) OUTPUT
		'

    EXECUTE sp_executesql @SqlCmd, @Params

                          , @Country_loc = @Country
                          , @Region_loc = @Region
                          , @City_loc = @City
                          , @PolygonWKT_loc = @PolygonWKT
                          , @POI_Category_loc = @POI_Category
                          , @POI_Name_loc = @POI_Name
                          , @Long_loc = @Long
                          , @Lat_loc = @Lat
                          , @Radius_loc = @Radius

						  , @OutputJson_Loc = @OutputJson OUTPUT;

	select '{ "type": "FeatureCollection", "features": ' + @OutputJson + '}'
end
GO
USE [master]
GO
ALTER DATABASE [PoiDB] SET  READ_WRITE 
GO
