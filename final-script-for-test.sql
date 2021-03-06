USE [master]
GO
/****** Object:  Database [dotaweb]    Script Date: 1/4/2017 5:32:24 PM ******/
CREATE DATABASE [dotaweb]
 CONTAINMENT = NONE
 ON  PRIMARY 
( NAME = N'dotaweb', FILENAME = N'C:\Program Files\Microsoft SQL Server\MSSQL12.MSSQLSERVER\MSSQL\DATA\dotaweb.mdf' , SIZE = 5120KB , MAXSIZE = UNLIMITED, FILEGROWTH = 1024KB )
 LOG ON 
( NAME = N'dotaweb_log', FILENAME = N'C:\Program Files\Microsoft SQL Server\MSSQL12.MSSQLSERVER\MSSQL\DATA\dotaweb_log.ldf' , SIZE = 2048KB , MAXSIZE = 2048GB , FILEGROWTH = 10%)
GO
ALTER DATABASE [dotaweb] SET COMPATIBILITY_LEVEL = 120
GO
IF (1 = FULLTEXTSERVICEPROPERTY('IsFullTextInstalled'))
begin
EXEC [dotaweb].[dbo].[sp_fulltext_database] @action = 'enable'
end
GO
ALTER DATABASE [dotaweb] SET ANSI_NULL_DEFAULT OFF 
GO
ALTER DATABASE [dotaweb] SET ANSI_NULLS OFF 
GO
ALTER DATABASE [dotaweb] SET ANSI_PADDING OFF 
GO
ALTER DATABASE [dotaweb] SET ANSI_WARNINGS OFF 
GO
ALTER DATABASE [dotaweb] SET ARITHABORT OFF 
GO
ALTER DATABASE [dotaweb] SET AUTO_CLOSE OFF 
GO
ALTER DATABASE [dotaweb] SET AUTO_SHRINK OFF 
GO
ALTER DATABASE [dotaweb] SET AUTO_UPDATE_STATISTICS ON 
GO
ALTER DATABASE [dotaweb] SET CURSOR_CLOSE_ON_COMMIT OFF 
GO
ALTER DATABASE [dotaweb] SET CURSOR_DEFAULT  GLOBAL 
GO
ALTER DATABASE [dotaweb] SET CONCAT_NULL_YIELDS_NULL OFF 
GO
ALTER DATABASE [dotaweb] SET NUMERIC_ROUNDABORT OFF 
GO
ALTER DATABASE [dotaweb] SET QUOTED_IDENTIFIER OFF 
GO
ALTER DATABASE [dotaweb] SET RECURSIVE_TRIGGERS OFF 
GO
ALTER DATABASE [dotaweb] SET  DISABLE_BROKER 
GO
ALTER DATABASE [dotaweb] SET AUTO_UPDATE_STATISTICS_ASYNC OFF 
GO
ALTER DATABASE [dotaweb] SET DATE_CORRELATION_OPTIMIZATION OFF 
GO
ALTER DATABASE [dotaweb] SET TRUSTWORTHY OFF 
GO
ALTER DATABASE [dotaweb] SET ALLOW_SNAPSHOT_ISOLATION OFF 
GO
ALTER DATABASE [dotaweb] SET PARAMETERIZATION SIMPLE 
GO
ALTER DATABASE [dotaweb] SET READ_COMMITTED_SNAPSHOT OFF 
GO
ALTER DATABASE [dotaweb] SET HONOR_BROKER_PRIORITY OFF 
GO
ALTER DATABASE [dotaweb] SET RECOVERY FULL 
GO
ALTER DATABASE [dotaweb] SET  MULTI_USER 
GO
ALTER DATABASE [dotaweb] SET PAGE_VERIFY CHECKSUM  
GO
ALTER DATABASE [dotaweb] SET DB_CHAINING OFF 
GO
ALTER DATABASE [dotaweb] SET FILESTREAM( NON_TRANSACTED_ACCESS = OFF ) 
GO
ALTER DATABASE [dotaweb] SET TARGET_RECOVERY_TIME = 0 SECONDS 
GO
ALTER DATABASE [dotaweb] SET DELAYED_DURABILITY = DISABLED 
GO
EXEC sys.sp_db_vardecimal_storage_format N'dotaweb', N'ON'
GO
USE [dotaweb]
GO
/****** Object:  UserDefinedFunction [dbo].[attack_condition]    Script Date: 1/4/2017 5:32:24 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date, ,>
-- Description:	<Description, ,>
-- =============================================
CREATE FUNCTION [dbo].[attack_condition](@attacker_username varchar(50),@defender_username varchar(50)) 
RETURNS int
AS
BEGIN

DECLARE @attacker_level int;
DECLARE @defender_level int;
DECLARE @defender_region int;
DECLARE @attacker_region int;
DECLARE @attacker_turn int;

SELECT	@attacker_turn = turn,
		@attacker_level = hero_level,
		@attacker_region = region
FROM user_hero,user_hero_virtual_attributes
WHERE user_hero.username = user_hero_virtual_attributes.username AND user_hero.username = @attacker_username

SELECT	@defender_region = region,
		@defender_level = hero_level
FROM user_hero,user_hero_virtual_attributes
WHERE user_hero.username = user_hero_virtual_attributes.username AND user_hero.username = @defender_username

IF (@attacker_turn >= 0 AND @attacker_region = @defender_region AND (ABS(@attacker_level-@defender_level) <=1) AND @defender_level != 0)
	BEGIN
		RETURN 1;
	END
	return NULL;
END



GO
/****** Object:  UserDefinedFunction [dbo].[calculate_agility]    Script Date: 1/4/2017 5:32:24 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date, ,>
-- Description:	<Description, ,>
-- =============================================
CREATE FUNCTION [dbo].[calculate_agility](@username varchar(50)) 
RETURNS int
AS
BEGIN
DECLARE @agility int;
DECLARE @base_agility int;
	SET @base_agility = dbo.calculate_base_agility(@username);
	SET @agility = @base_agility;
	DECLARE myCur CURSOR LOCAL FOR
		SELECT item.agility,item.per_agility
		FROM user_item,item
		WHERE user_item.username = @username and  item.id = user_item.item_id and user_item.sold !=0
	OPEN myCur
	DECLARE @agility_change_val int;
	DECLARE @agility_change_per int;
	FETCH NEXT FROM myCur INTO @agility_change_val,@agility_change_per
	WHILE @@FETCH_STATUS = 0
	BEGIN
		IF (@agility_change_val IS NULL) SET @agility_change_val = 0;
		IF (@agility_change_per IS NULL) SET @agility_change_per = 0;
		SET @agility += @agility_change_val + @base_agility*@agility_change_per;
		FETCH NEXT FROM myCur INTO  @agility_change_val,@agility_change_per
	END
	CLOSE myCur
DEALLOCATE myCur
RETURN @agility;
END



GO
/****** Object:  UserDefinedFunction [dbo].[calculate_armor]    Script Date: 1/4/2017 5:32:24 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date, ,>
-- Description:	<Description, ,>
-- =============================================
CREATE FUNCTION [dbo].[calculate_armor](@username varchar(50))
RETURNS int
AS
BEGIN
	DECLARE @armor int;
	DECLARE @base_armor int;
	SET @base_armor = 
						(
							SELECT dbo.calculate_agility(@username)
						)
	SET @armor = @base_armor;
	DECLARE myCur CURSOR LOCAL FOR
		SELECT item.armor,item.per_armor
		FROM user_item,item
		WHERE user_item.username = @username and item.id = user_item.item_id and user_item.sold !=0
	OPEN myCur
	DECLARE @armor_change_val int;
	DECLARE @armor_change_per int;
	FETCH NEXT FROM myCur INTO @armor_change_val,@armor_change_per
	WHILE @@FETCH_STATUS = 0
	BEGIN
		IF (@armor_change_val IS NULL) SET @armor_change_val = 0;
		IF (@armor_change_per IS NULL) SET @armor_change_per = 0;
		SET @armor += @armor_change_val + @base_armor*@armor_change_per;
		FETCH NEXT FROM myCur INTO  @armor_change_val,@armor_change_per
	END
	CLOSE myCur
DEALLOCATE myCur
RETURN @armor;


END



GO
/****** Object:  UserDefinedFunction [dbo].[calculate_attack]    Script Date: 1/4/2017 5:32:24 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date, ,>
-- Description:	<Description, ,>
-- =============================================
CREATE FUNCTION [dbo].[calculate_attack](@username varchar(50))
RETURNS int
AS
BEGIN
	DECLARE @attack int;
	DECLARE @base_attack int;
	SET @base_attack = 2* dbo.calculate_strength(@username);
	SET @attack = @base_attack;
	DECLARE myCur CURSOR LOCAL FOR
		SELECT item.attack,item.per_attack
		FROM user_item,item
		WHERE user_item.username = @username and  item.id = user_item.item_id and user_item.sold !=0
	OPEN myCur
	DECLARE @base_attack_change_val int;
	DECLARE @base_attack_change_per int;
	FETCH NEXT FROM myCur INTO @base_attack_change_val,@base_attack_change_per
	WHILE @@FETCH_STATUS = 0
	BEGIN
		IF (@base_attack_change_val IS NULL) SET @base_attack_change_val = 0;
		IF (@base_attack_change_per IS NULL) SET @base_attack_change_per = 0;
		SET @attack += @base_attack_change_val + @base_attack*@base_attack_change_per;
		FETCH NEXT FROM myCur INTO  @base_attack_change_val,@base_attack_change_per
	END
	CLOSE myCur
DEALLOCATE myCur
	RETURN @attack;
END



GO
/****** Object:  UserDefinedFunction [dbo].[calculate_base_agility]    Script Date: 1/4/2017 5:32:24 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date, ,>
-- Description:	<Description, ,>
-- =============================================
CREATE FUNCTION [dbo].[calculate_base_agility](@username varchar(50)) 
RETURNS int
AS
BEGIN
	DECLARE @base_agility int;
	SET @base_agility = 
						(
							SELECT t2.agility
							FROM user_hero AS t1,hero AS t2
							WHERE t1.hero_id = t2.id and t1.username = @username
						)
	RETURN @base_agility;
END



GO
/****** Object:  UserDefinedFunction [dbo].[calculate_base_hp]    Script Date: 1/4/2017 5:32:24 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE FUNCTION [dbo].[calculate_base_hp](@username varchar(50)) 
RETURNS int
AS
BEGIN
	DECLARE @base_base_hp int;
	DECLARE @base_hp int;
	SET @base_base_hp = 75.55 * dbo.calculate_strength(@username);
	SET @base_hp = @base_base_hp;
	DECLARE myCur CURSOR LOCAL FOR
		SELECT item.base_hp,item.per_base_hp
		FROM user_item,item
		WHERE user_item.username = @username and  item.id = user_item.item_id and user_item.sold !=0
	OPEN myCur
	DECLARE @base_hp_change_val int;
	DECLARE @base_hp_change_per int;
	FETCH NEXT FROM myCur INTO @base_hp_change_val,@base_hp_change_per
	WHILE @@FETCH_STATUS = 0
	BEGIN
		IF (@base_hp_change_val IS NULL) SET @base_hp_change_val = 0;
		IF (@base_hp_change_per IS NULL) SET @base_hp_change_per = 0;
		SET @base_hp += @base_hp_change_val + @base_base_hp*@base_hp_change_per;
		FETCH NEXT FROM myCur INTO  @base_hp_change_val,@base_hp_change_per
	END
	CLOSE myCur
DEALLOCATE myCur
	RETURN @base_hp;
END



GO
/****** Object:  UserDefinedFunction [dbo].[calculate_base_intelligence]    Script Date: 1/4/2017 5:32:24 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date, ,>
-- Description:	<Description, ,>
-- =============================================
CREATE FUNCTION [dbo].[calculate_base_intelligence](@username varchar(50))
RETURNS int
AS
BEGIN
		DECLARE @base_intelligence int;
	SET @base_intelligence = 
						(
							SELECT t2.intelligence
							FROM user_hero AS t1,hero AS t2
							WHERE t1.hero_id = t2.id and t1.username = @username
						)
	RETURN @base_intelligence;
END



GO
/****** Object:  UserDefinedFunction [dbo].[calculate_base_mana]    Script Date: 1/4/2017 5:32:24 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date, ,>
-- Description:	<Description, ,>
-- =============================================
CREATE FUNCTION [dbo].[calculate_base_mana](@username varchar(50))
RETURNS int
AS
BEGIN
	DECLARE @base_base_mana int;
	DECLARE @base_mana int;
	SET @base_base_mana = 80 * dbo.calculate_intelligence(@username);
	SET @base_mana = @base_base_mana;
	DECLARE myCur CURSOR LOCAL FOR
		SELECT item.base_mana,item.per_base_mana
		FROM user_item,item
		WHERE user_item.username = @username and  item.id = user_item.item_id and user_item.sold !=0
	OPEN myCur
	DECLARE @base_mana_change_val int;
	DECLARE @base_mana_change_per int;
	FETCH NEXT FROM myCur INTO @base_mana_change_val,@base_mana_change_per
	WHILE @@FETCH_STATUS = 0
	BEGIN
		IF (@base_mana_change_val IS NULL) SET @base_mana_change_val = 0;
		IF (@base_mana_change_per IS NULL) SET @base_mana_change_per = 0;
		SET @base_mana += @base_mana_change_val + @base_base_mana*@base_mana_change_per;
		FETCH NEXT FROM myCur INTO  @base_mana_change_val,@base_mana_change_per
	END
	CLOSE myCur
DEALLOCATE myCur
	RETURN @base_mana;
END


GO
/****** Object:  UserDefinedFunction [dbo].[calculate_base_strength]    Script Date: 1/4/2017 5:32:24 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date, ,>
-- Description:	<Description, ,>
-- =============================================
CREATE FUNCTION [dbo].[calculate_base_strength](@username varchar(50))
RETURNS int
AS
BEGIN
		DECLARE @base_strength int;
	SET @base_strength = 
						(
							SELECT t2.strength
							FROM user_hero AS t1,hero AS t2
							WHERE t1.hero_id = t2.id and t1.username = @username
						)
	RETURN @base_strength;
END



GO
/****** Object:  UserDefinedFunction [dbo].[calculate_hero_level]    Script Date: 1/4/2017 5:32:24 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date, ,>
-- Description:	<Description, ,>
-- =============================================
CREATE FUNCTION [dbo].[calculate_hero_level](@username varchar(50)) 
RETURNS int
AS
BEGIN
	DECLARE @hero_level int;
	DECLARE @exp int;
	SET @exp = 
				(
					SELECT experience FROM user_hero WHERE username = @username
				)
	SET @hero_level =  CASE  
						WHEN 1000 <= @exp AND @exp <=3000  THEN 1
						WHEN 3001 <= @exp AND @exp <=4500  THEN 2 
						WHEN 4501 <= @exp AND @exp <=6750  THEN 3
						WHEN 6751 <= @exp AND @exp <=11225  THEN 4
						WHEN 11226 <= @exp THEN 5
						ELSE @hero_level
                    END
    RETURN @hero_level;
END



GO
/****** Object:  UserDefinedFunction [dbo].[calculate_intelligence]    Script Date: 1/4/2017 5:32:24 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date, ,>
-- Description:	<Description, ,>
-- =============================================
CREATE FUNCTION [dbo].[calculate_intelligence](@username varchar(50)) 
RETURNS int
AS
BEGIN
	DECLARE @intelligence int;
	DECLARE @base_intelligence int;
	SET @base_intelligence = dbo.calculate_base_intelligence(@username);
	SET @intelligence = @base_intelligence;
	DECLARE myCur CURSOR LOCAL FOR
		SELECT item.intelligence,item.per_intelligence
		FROM user_item,item
		WHERE user_item.username = @username and  item.id = user_item.item_id and user_item.sold !=0
	OPEN myCur
	DECLARE @intelligence_change_val int;
	DECLARE @intelligence_change_per int;
	FETCH NEXT FROM myCur INTO @intelligence_change_val,@intelligence_change_per
	WHILE @@FETCH_STATUS = 0
	BEGIN
		IF (@intelligence_change_val IS NULL) SET @intelligence_change_val = 0;
		IF (@intelligence_change_per IS NULL) SET @intelligence_change_per = 0;
		SET @intelligence += @intelligence_change_val + @base_intelligence*@intelligence_change_per;
		FETCH NEXT FROM myCur INTO  @intelligence_change_val,@intelligence_change_per
	END
	CLOSE myCur
DEALLOCATE myCur
RETURN @intelligence;
END


GO
/****** Object:  UserDefinedFunction [dbo].[calculate_score]    Script Date: 1/4/2017 5:32:24 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date, ,>
-- Description:	<Description, ,>
-- =============================================
CREATE FUNCTION [dbo].[calculate_score](@username varchar(50))
RETURNS int
AS
BEGIN
	DECLARE @score int;
	SET @score = 
		(
			SELECT kills*4 + assistance - deaths*3 + dbo.calculate_hero_level(@username)
			FROM user_hero
			WHERE username = @username
		)
	RETURN @score;
END



GO
/****** Object:  UserDefinedFunction [dbo].[calculate_strength]    Script Date: 1/4/2017 5:32:24 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE FUNCTION [dbo].[calculate_strength](@username varchar(50)) 
RETURNS int
AS
BEGIN
	DECLARE @strength int;
	DECLARE @base_strength int;
	SET @base_strength = dbo.calculate_base_strength(@username);
	SET @strength = @base_strength;
	DECLARE myCur CURSOR LOCAL FOR
		SELECT item.strength,item.per_strength
		FROM user_item,item
		WHERE user_item.username = @username and  item.id = user_item.item_id and user_item.sold !=0
	OPEN myCur
	DECLARE @strength_change_val int;
	DECLARE @strength_change_per int;
	FETCH NEXT FROM myCur INTO @strength_change_val,@strength_change_per
	WHILE @@FETCH_STATUS = 0
	BEGIN
		IF (@strength_change_val IS NULL) SET @strength_change_val = 0;
		IF (@strength_change_per IS NULL) SET @strength_change_per = 0;
		SET @strength += @strength_change_val + @base_strength*@strength_change_per;
		FETCH NEXT FROM myCur INTO  @strength_change_val,@strength_change_per
	END
	CLOSE myCur
DEALLOCATE myCur
RETURN @strength;
END



GO
/****** Object:  UserDefinedFunction [dbo].[is_death]    Script Date: 1/4/2017 5:32:24 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date, ,>
-- Description:	<Description, ,>
-- =============================================
CREATE FUNCTION [dbo].[is_death](@username varchar(50)) 
RETURNS int
AS
BEGIN
	DECLARE @user_hp int;
	SELECT @user_hp = hp
	FROM user_hero
	WHERE username = @username
	IF (@user_hp <= 0 )
	BEGIN
		RETURN 1;
	END
	RETURN 0;
END



GO
/****** Object:  UserDefinedFunction [dbo].[minimum]    Script Date: 1/4/2017 5:32:24 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date, ,>
-- Description:	<Description, ,>
-- =============================================
CREATE FUNCTION [dbo].[minimum] (@val1 int,@val2 int)
RETURNS int
AS
BEGIN
	IF (@val1 > @val2)
	BEGIN
		RETURN @val2;
	END
	RETURN @val1;
END



GO
/****** Object:  Table [dbo].[assistance]    Script Date: 1/4/2017 5:32:24 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[assistance](
	[victim_username] [varchar](50) NOT NULL,
	[assistant_username] [varchar](50) NOT NULL,
 CONSTRAINT [PK_assistance] PRIMARY KEY CLUSTERED 
(
	[victim_username] ASC,
	[assistant_username] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[attack_log]    Script Date: 1/4/2017 5:32:25 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[attack_log](
	[id] [int] IDENTITY(1,1) NOT NULL,
	[defender_username] [varchar](50) NOT NULL,
	[attacker_username] [varchar](50) NOT NULL,
	[attack_type] [int] NOT NULL,
	[attacker_damage] [int] NULL,
	[defender_damage] [int] NULL,
	[time] [datetime] NOT NULL,
	[region] [int] NOT NULL,
	[spell_id] [nchar](10) NULL,
	[is_attacker_killed] [int] NOT NULL,
	[is_defender_killed] [int] NOT NULL,
 CONSTRAINT [PK_attack_log] PRIMARY KEY CLUSTERED 
(
	[id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[config]    Script Date: 1/4/2017 5:32:25 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[config](
	[id] [int] IDENTITY(1,1) NOT NULL,
	[name] [varchar](50) NOT NULL,
	[value] [varchar](50) NOT NULL,
 CONSTRAINT [PK_config] PRIMARY KEY CLUSTERED 
(
	[id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[hero]    Script Date: 1/4/2017 5:32:25 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[hero](
	[id] [int] IDENTITY(1,1) NOT NULL,
	[name] [varchar](50) NOT NULL,
	[strength] [int] NOT NULL,
	[intelligence] [int] NOT NULL,
	[agility] [int] NOT NULL,
	[ptype] [int] NOT NULL,
	[default_team] [int] NOT NULL,
	[logo] [varchar](200) NOT NULL,
	[uniqueness_sp] [varchar](50) NOT NULL,
 CONSTRAINT [PK_hero] PRIMARY KEY CLUSTERED 
(
	[id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[item]    Script Date: 1/4/2017 5:32:25 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[item](
	[id] [int] IDENTITY(1,1) NOT NULL,
	[logo] [varchar](200) NOT NULL,
	[name] [varchar](50) NOT NULL,
	[price] [int] NOT NULL,
	[region] [int] NOT NULL,
	[intelligence] [int] NULL,
	[agility] [int] NULL,
	[strength] [int] NULL,
	[hp] [int] NULL,
	[mana] [int] NULL,
	[attack] [int] NULL,
	[armor] [int] NULL,
	[base_hp] [int] NULL,
	[base_mana] [int] NULL,
	[cycle_hp] [int] NULL,
	[cycle_mana] [int] NULL,
	[cyclic] [int] NULL,
	[per_strength] [int] NULL,
	[per_intelligence] [int] NULL,
	[per_agility] [int] NULL,
	[per_mana] [int] NULL,
	[per_hp] [int] NULL,
	[per_attack] [int] NULL,
	[per_armor] [int] NULL,
	[per_base_hp] [int] NULL,
	[per_base_mana] [int] NULL,
	[item_level] [int] NULL,
 CONSTRAINT [PK_item] PRIMARY KEY CLUSTERED 
(
	[id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[kill_log]    Script Date: 1/4/2017 5:32:25 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[kill_log](
	[id] [int] IDENTITY(1,1) NOT NULL,
	[killer_username] [varchar](50) NOT NULL,
	[victim_username] [varchar](50) NOT NULL,
	[region] [int] NOT NULL,
	[time] [datetime] NOT NULL,
 CONSTRAINT [PK_kill_log] PRIMARY KEY CLUSTERED 
(
	[id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[match_log]    Script Date: 1/4/2017 5:32:25 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[match_log](
	[id] [int] IDENTITY(1,1) NOT NULL,
	[killer_username] [varchar](50) NOT NULL,
	[killed_username] [varchar](50) NOT NULL,
	[time] [datetime] NOT NULL,
 CONSTRAINT [PK_match_log] PRIMARY KEY CLUSTERED 
(
	[id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[spell]    Script Date: 1/4/2017 5:32:25 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[spell](
	[id] [int] IDENTITY(1,1) NOT NULL,
	[name] [varchar](200) NOT NULL,
	[description] [varchar](500) NOT NULL,
	[hero_level] [int] NOT NULL,
	[apply_sp] [varchar](200) NOT NULL,
	[cost] [int] NOT NULL,
 CONSTRAINT [PK_spell] PRIMARY KEY CLUSTERED 
(
	[id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[user_hero]    Script Date: 1/4/2017 5:32:25 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[user_hero](
	[username] [varchar](50) NOT NULL,
	[password] [varchar](50) NOT NULL,
	[full_name] [varchar](50) NOT NULL,
	[city] [varchar](50) NOT NULL,
	[email] [varchar](50) NOT NULL,
	[country] [varchar](50) NOT NULL,
	[age] [int] NOT NULL,
	[experience] [int] NULL CONSTRAINT [DF_user_hero_exprience]  DEFAULT ((1000)),
	[region] [int] NULL CONSTRAINT [DF_user_hero_region]  DEFAULT ((0)),
	[turn] [int] NULL CONSTRAINT [DF_user_hero_turn]  DEFAULT ((0)),
	[kill_streak] [int] NULL CONSTRAINT [DF_user_hero_kill_streak]  DEFAULT ((0)),
	[kills] [int] NULL CONSTRAINT [DF_user_hero_kills]  DEFAULT ((0)),
	[deaths] [int] NULL CONSTRAINT [DF_user_hero_deaths]  DEFAULT ((0)),
	[assistance] [int] NULL CONSTRAINT [DF_user_hero_assistance]  DEFAULT ((0)),
	[team] [int] NULL,
	[gold] [int] NULL CONSTRAINT [DF_user_hero_gold]  DEFAULT ((0)),
	[hp] [int] NULL CONSTRAINT [DF_user_hero_hp]  DEFAULT ((0)),
	[mana] [int] NULL CONSTRAINT [DF_user_hero_mana]  DEFAULT ((0)),
	[hero_id] [int] NOT NULL,
	[free_slot] [int] NULL,
	[is_terrored] [int] NULL,
	[has_bounce_attack] [int] NULL,
 CONSTRAINT [PK_user_hero] PRIMARY KEY CLUSTERED 
(
	[username] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[user_item]    Script Date: 1/4/2017 5:32:25 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[user_item](
	[id] [int] IDENTITY(1,1) NOT NULL,
	[username] [varchar](50) NOT NULL,
	[item_id] [int] NOT NULL,
	[sold] [int] NULL,
 CONSTRAINT [PK_user_item] PRIMARY KEY CLUSTERED 
(
	[id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  View [dbo].[user_hero_virtual_attributes]    Script Date: 1/4/2017 5:32:25 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [dbo].[user_hero_virtual_attributes]
AS
SELECT        username, score, agility, strength, intelligence, attack, base_mana, base_hp, hero_level, armor,
                             (SELECT        1 + COUNT(*) AS Expr1
                                FROM            (SELECT        username, dbo.calculate_score(username) AS score, dbo.calculate_agility(username) AS agility, dbo.calculate_strength(username) AS strength, dbo.calculate_intelligence(username) 
                                                                                    AS intelligence, dbo.calculate_attack(username) AS attack, dbo.calculate_base_mana(username) AS base_mana, dbo.calculate_base_hp(username) AS base_hp, 
                                                                                    dbo.calculate_hero_level(username) AS hero_level, dbo.calculate_armor(username) AS armor
                                                           FROM            dbo.user_hero) AS t2
                                WHERE        (score > t1.score)) AS rank
FROM            (SELECT        username, dbo.calculate_score(username) AS score, dbo.calculate_agility(username) AS agility, dbo.calculate_strength(username) AS strength, dbo.calculate_intelligence(username) AS intelligence, 
                                                    dbo.calculate_attack(username) AS attack, dbo.calculate_base_mana(username) AS base_mana, dbo.calculate_base_hp(username) AS base_hp, dbo.calculate_hero_level(username) AS hero_level, 
                                                    dbo.calculate_armor(username) AS armor
                           FROM            dbo.user_hero AS user_hero_1) AS t1



GO
SET IDENTITY_INSERT [dbo].[attack_log] ON 

INSERT [dbo].[attack_log] ([id], [defender_username], [attacker_username], [attack_type], [attacker_damage], [defender_damage], [time], [region], [spell_id], [is_attacker_killed], [is_defender_killed]) VALUES (2, N'ali', N'sin', 0, 10, 22, CAST(N'2017-01-03 18:24:30.000' AS DateTime), 2, N'1         ', 0, 0)
SET IDENTITY_INSERT [dbo].[attack_log] OFF
SET IDENTITY_INSERT [dbo].[config] ON 

INSERT [dbo].[config] ([id], [name], [value]) VALUES (1, N'max_slot', N'6')
INSERT [dbo].[config] ([id], [name], [value]) VALUES (2, N'kill_exp', N'100')
INSERT [dbo].[config] ([id], [name], [value]) VALUES (3, N'heal_cost', N'50')
SET IDENTITY_INSERT [dbo].[config] OFF
SET IDENTITY_INSERT [dbo].[hero] ON 

INSERT [dbo].[hero] ([id], [name], [strength], [intelligence], [agility], [ptype], [default_team], [logo], [uniqueness_sp]) VALUES (4, N'ali', 20, 13, 41, 2, 1, N'http://www.webdota.net/image/hero/sc_naix.gif', N'sthe')
INSERT [dbo].[hero] ([id], [name], [strength], [intelligence], [agility], [ptype], [default_team], [logo], [uniqueness_sp]) VALUES (5, N'dexter', 50, 100, 39, 3, 0, N'http://www.webdota.net/image/hero/st_antimage.gif', N'kill')
INSERT [dbo].[hero] ([id], [name], [strength], [intelligence], [agility], [ptype], [default_team], [logo], [uniqueness_sp]) VALUES (7, N'Holy Knight', 19, 20, 14, 2, 0, N'http://www.webdota.net/image/hero/st_chen.gif', N'uniq_holy_knight')
INSERT [dbo].[hero] ([id], [name], [strength], [intelligence], [agility], [ptype], [default_team], [logo], [uniqueness_sp]) VALUES (8, N'Pandaren Battlemaster', 22, 13, 15, 1, 0, N'http://www.webdota.net/image/hero/st_pandaren.gif', N'uniq_pendaren_battlemaster')
SET IDENTITY_INSERT [dbo].[hero] OFF
SET IDENTITY_INSERT [dbo].[item] ON 

INSERT [dbo].[item] ([id], [logo], [name], [price], [region], [intelligence], [agility], [strength], [hp], [mana], [attack], [armor], [base_hp], [base_mana], [cycle_hp], [cycle_mana], [cyclic], [per_strength], [per_intelligence], [per_agility], [per_mana], [per_hp], [per_attack], [per_armor], [per_base_hp], [per_base_mana], [item_level]) VALUES (5, N'http://www.webdota.net/image/item/potion_hp.jpg', N'Flask of Sapphire Water', 200, 1, 0, 0, 0, 500, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1)
INSERT [dbo].[item] ([id], [logo], [name], [price], [region], [intelligence], [agility], [strength], [hp], [mana], [attack], [armor], [base_hp], [base_mana], [cycle_hp], [cycle_mana], [cyclic], [per_strength], [per_intelligence], [per_agility], [per_mana], [per_hp], [per_attack], [per_armor], [per_base_hp], [per_base_mana], [item_level]) VALUES (6, N'http://www.webdota.net/image/item/clarity.jpg', N'Lesser Clarity Portion', 200, 1, 0, 0, 0, 0, 500, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1)
INSERT [dbo].[item] ([id], [logo], [name], [price], [region], [intelligence], [agility], [strength], [hp], [mana], [attack], [armor], [base_hp], [base_mana], [cycle_hp], [cycle_mana], [cyclic], [per_strength], [per_intelligence], [per_agility], [per_mana], [per_hp], [per_attack], [per_armor], [per_base_hp], [per_base_mana], [item_level]) VALUES (8, N'http://www.webdota.net/image/item/ironwood.jpg', N'Ironwood Branch', 200, 2, 1, 1, 1, 1, 1, 1, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1)
INSERT [dbo].[item] ([id], [logo], [name], [price], [region], [intelligence], [agility], [strength], [hp], [mana], [attack], [armor], [base_hp], [base_mana], [cycle_hp], [cycle_mana], [cyclic], [per_strength], [per_intelligence], [per_agility], [per_mana], [per_hp], [per_attack], [per_armor], [per_base_hp], [per_base_mana], [item_level]) VALUES (9, N'http://www.webdota.net/image/item/bottle.jpg', N'Bottle', 200, 2, 0, 0, 0, 250, 250, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1)
INSERT [dbo].[item] ([id], [logo], [name], [price], [region], [intelligence], [agility], [strength], [hp], [mana], [attack], [armor], [base_hp], [base_mana], [cycle_hp], [cycle_mana], [cyclic], [per_strength], [per_intelligence], [per_agility], [per_mana], [per_hp], [per_attack], [per_armor], [per_base_hp], [per_base_mana], [item_level]) VALUES (10, N'http://www.webdota.net/image/item/blade.jpg', N'Blades of Attack', 500, 2, 0, 0, 0, 0, 0, 10, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1)
INSERT [dbo].[item] ([id], [logo], [name], [price], [region], [intelligence], [agility], [strength], [hp], [mana], [attack], [armor], [base_hp], [base_mana], [cycle_hp], [cycle_mana], [cyclic], [per_strength], [per_intelligence], [per_agility], [per_mana], [per_hp], [per_attack], [per_armor], [per_base_hp], [per_base_mana], [item_level]) VALUES (11, N'http://www.webdota.net/image/item/gauntlets.jpg', N'Gauntlets of Ogre Strength', 850, 2, 0, 0, 4, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1)
INSERT [dbo].[item] ([id], [logo], [name], [price], [region], [intelligence], [agility], [strength], [hp], [mana], [attack], [armor], [base_hp], [base_mana], [cycle_hp], [cycle_mana], [cyclic], [per_strength], [per_intelligence], [per_agility], [per_mana], [per_hp], [per_attack], [per_armor], [per_base_hp], [per_base_mana], [item_level]) VALUES (13, N'http://www.webdota.net/image/item/slippers.jpg', N'Slippers of Agility', 850, 2, 0, 4, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1)
INSERT [dbo].[item] ([id], [logo], [name], [price], [region], [intelligence], [agility], [strength], [hp], [mana], [attack], [armor], [base_hp], [base_mana], [cycle_hp], [cycle_mana], [cyclic], [per_strength], [per_intelligence], [per_agility], [per_mana], [per_hp], [per_attack], [per_armor], [per_base_hp], [per_base_mana], [item_level]) VALUES (14, N'http://www.webdota.net/image/item/mantle.jpg', N'Mantle of Intelligence', 850, 2, 4, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1)
INSERT [dbo].[item] ([id], [logo], [name], [price], [region], [intelligence], [agility], [strength], [hp], [mana], [attack], [armor], [base_hp], [base_mana], [cycle_hp], [cycle_mana], [cyclic], [per_strength], [per_intelligence], [per_agility], [per_mana], [per_hp], [per_attack], [per_armor], [per_base_hp], [per_base_mana], [item_level]) VALUES (15, N'http://www.webdota.net/image/item/sobimask.jpg', N'Sobi Mask', 1800, 2, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 500, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1)
INSERT [dbo].[item] ([id], [logo], [name], [price], [region], [intelligence], [agility], [strength], [hp], [mana], [attack], [armor], [base_hp], [base_mana], [cycle_hp], [cycle_mana], [cyclic], [per_strength], [per_intelligence], [per_agility], [per_mana], [per_hp], [per_attack], [per_armor], [per_base_hp], [per_base_mana], [item_level]) VALUES (16, N'http://www.webdota.net/image/item/ringregen.jpg', N'Ring of Regeneration', 3000, 2, 0, 0, 0, 0, 0, 0, 0, 0, 0, 350, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1)
SET IDENTITY_INSERT [dbo].[item] OFF
SET IDENTITY_INSERT [dbo].[kill_log] ON 

INSERT [dbo].[kill_log] ([id], [killer_username], [victim_username], [region], [time]) VALUES (1, N'ali', N'sina', 2, CAST(N'2017-01-03 18:24:30.000' AS DateTime))
SET IDENTITY_INSERT [dbo].[kill_log] OFF
SET IDENTITY_INSERT [dbo].[spell] ON 

INSERT [dbo].[spell] ([id], [name], [description], [hero_level], [apply_sp], [cost]) VALUES (1, N'Lightning Bolt', N'The basic magic attack.', 1, N'spell_lightning_bolt', 450)
INSERT [dbo].[spell] ([id], [name], [description], [hero_level], [apply_sp], [cost]) VALUES (2, N'Gold Spy', N'This magic will give an estimate of gold reserve of an opponent.', 1, N'spell_gold_spy', 200)
INSERT [dbo].[spell] ([id], [name], [description], [hero_level], [apply_sp], [cost]) VALUES (3, N'Hero Spy', N'Provide basic information of an opponent.', 1, N'spell_hero_spy', 150)
INSERT [dbo].[spell] ([id], [name], [description], [hero_level], [apply_sp], [cost]) VALUES (4, N'Terror', N'Disable enemy’s armor for 1 turn and enemy has no return damage for that turn.', 1, N'spell_terror', 500)
INSERT [dbo].[spell] ([id], [name], [description], [hero_level], [apply_sp], [cost]) VALUES (5, N'Gush', N'Deadly magic attack learned from legendary Leviathan.', 2, N'spell_gush', 500)
INSERT [dbo].[spell] ([id], [name], [description], [hero_level], [apply_sp], [cost]) VALUES (6, N'Mana Burn', N'Burn up to 15% of enemy mana pool.', 2, N'spell_mana_burn', 300)
INSERT [dbo].[spell] ([id], [name], [description], [hero_level], [apply_sp], [cost]) VALUES (7, N'Gold Hunger', N'Destroy big portion of enemy’s gold reserve.', 3, N'spell_gold_hunger', 500)
INSERT [dbo].[spell] ([id], [name], [description], [hero_level], [apply_sp], [cost]) VALUES (8, N'Bounce Attack', N'Protection spell to bounce next attack against you back to enemy.', 3, N'spell_bounce_attack', 1000)
INSERT [dbo].[spell] ([id], [name], [description], [hero_level], [apply_sp], [cost]) VALUES (9, N'Death Coil', N'Coil of death that rips at a target.', 4, N'spell_death_coil', 850)
INSERT [dbo].[spell] ([id], [name], [description], [hero_level], [apply_sp], [cost]) VALUES (10, N'Brand Sap', N'Take portion of enemy HP to heal yourself.', 5, N'spell_brand_sap', 850)
INSERT [dbo].[spell] ([id], [name], [description], [hero_level], [apply_sp], [cost]) VALUES (11, N'Finger of Death', N'Deadly spell that almost kill an enemy. (Level 7 spell if not in War)', 6, N'spell_finger_of_death', 900)
INSERT [dbo].[spell] ([id], [name], [description], [hero_level], [apply_sp], [cost]) VALUES (12, N'Sunder', N'Switch soul between enemy and you, thus carry enemy health and mana.', 6, N'spell_sunder', 1500)
INSERT [dbo].[spell] ([id], [name], [description], [hero_level], [apply_sp], [cost]) VALUES (13, N'Sunder Health', N'Switch health pool with your enemy.', 6, N'spell_sunder_health', 1500)
SET IDENTITY_INSERT [dbo].[spell] OFF
INSERT [dbo].[user_hero] ([username], [password], [full_name], [city], [email], [country], [age], [experience], [region], [turn], [kill_streak], [kills], [deaths], [assistance], [team], [gold], [hp], [mana], [hero_id], [free_slot], [is_terrored], [has_bounce_attack]) VALUES (N'a.eb', N'123', N'ali eb', N'tehran', N'a.eb@eb.com', N'iran', 22, 1000, 2, 18, 0, 0, 0, 0, 1, 2480, 1511, 1040, 7, 6, NULL, NULL)
INSERT [dbo].[user_hero] ([username], [password], [full_name], [city], [email], [country], [age], [experience], [region], [turn], [kill_streak], [kills], [deaths], [assistance], [team], [gold], [hp], [mana], [hero_id], [free_slot], [is_terrored], [has_bounce_attack]) VALUES (N'ali', N'1212', N'aliebram', N'tehran', N'ali@gmail.com', N'iran', 22, 3002, 3, 18, 0, 0, 0, 0, 0, 2610, 100, 200, 8, 6, NULL, NULL)
INSERT [dbo].[user_hero] ([username], [password], [full_name], [city], [email], [country], [age], [experience], [region], [turn], [kill_streak], [kills], [deaths], [assistance], [team], [gold], [hp], [mana], [hero_id], [free_slot], [is_terrored], [has_bounce_attack]) VALUES (N'amiiigh', N'123456', N'amirhossein', N'tehran', N'ghafari.ah@gmail.com', N'iran', 22, 6800, 3, 18, 0, 0, 0, 0, 1, 4640, 100, 0, 8, 6, NULL, NULL)
INSERT [dbo].[user_hero] ([username], [password], [full_name], [city], [email], [country], [age], [experience], [region], [turn], [kill_streak], [kills], [deaths], [assistance], [team], [gold], [hp], [mana], [hero_id], [free_slot], [is_terrored], [has_bounce_attack]) VALUES (N'rynemason', N'ryn123', N'rynemason', N'tehran', N'mason@gmail.com', N'iran', 28, 1000, 3, 19, 0, 0, 0, 0, 1, 3950, 100, 500, 7, 6, NULL, NULL)
INSERT [dbo].[user_hero] ([username], [password], [full_name], [city], [email], [country], [age], [experience], [region], [turn], [kill_streak], [kills], [deaths], [assistance], [team], [gold], [hp], [mana], [hero_id], [free_slot], [is_terrored], [has_bounce_attack]) VALUES (N'sepehr', N'abc123', N'sepehr sepehr', N'tehran', N'sina@sina.com', N'iran', 22, 1000, 3, 18, 0, 0, 0, 0, 0, 1010, 1662, 1040, 8, 6, NULL, NULL)
INSERT [dbo].[user_hero] ([username], [password], [full_name], [city], [email], [country], [age], [experience], [region], [turn], [kill_streak], [kills], [deaths], [assistance], [team], [gold], [hp], [mana], [hero_id], [free_slot], [is_terrored], [has_bounce_attack]) VALUES (N'sina', N'abc123', N'sina rezaei', N'tehran', N'sina@sina.com', N'iran', 22, 1000, 3, 16, 0, 0, 0, 0, 0, 9860, 1435, 1600, 7, 1, NULL, NULL)
SET IDENTITY_INSERT [dbo].[user_item] ON 

INSERT [dbo].[user_item] ([id], [username], [item_id], [sold]) VALUES (7, N'sina', 13, 1)
INSERT [dbo].[user_item] ([id], [username], [item_id], [sold]) VALUES (8, N'sina', 9, 1)
INSERT [dbo].[user_item] ([id], [username], [item_id], [sold]) VALUES (9, N'sina', 5, 1)
INSERT [dbo].[user_item] ([id], [username], [item_id], [sold]) VALUES (10, N'sina', 5, 1)
INSERT [dbo].[user_item] ([id], [username], [item_id], [sold]) VALUES (11, N'sina', 5, 1)
INSERT [dbo].[user_item] ([id], [username], [item_id], [sold]) VALUES (12, N'sina', 6, 1)
INSERT [dbo].[user_item] ([id], [username], [item_id], [sold]) VALUES (13, N'sina', 6, 1)
INSERT [dbo].[user_item] ([id], [username], [item_id], [sold]) VALUES (14, N'sina', 5, 1)
INSERT [dbo].[user_item] ([id], [username], [item_id], [sold]) VALUES (15, N'sina', 5, 1)
INSERT [dbo].[user_item] ([id], [username], [item_id], [sold]) VALUES (16, N'sina', 5, 1)
INSERT [dbo].[user_item] ([id], [username], [item_id], [sold]) VALUES (17, N'sina', 5, 1)
INSERT [dbo].[user_item] ([id], [username], [item_id], [sold]) VALUES (18, N'sina', 5, 1)
INSERT [dbo].[user_item] ([id], [username], [item_id], [sold]) VALUES (19, N'sina', 6, 1)
INSERT [dbo].[user_item] ([id], [username], [item_id], [sold]) VALUES (20, N'sina', 6, 1)
INSERT [dbo].[user_item] ([id], [username], [item_id], [sold]) VALUES (21, N'sina', 5, 1)
INSERT [dbo].[user_item] ([id], [username], [item_id], [sold]) VALUES (22, N'sina', 5, 1)
INSERT [dbo].[user_item] ([id], [username], [item_id], [sold]) VALUES (23, N'sina', 5, 1)
INSERT [dbo].[user_item] ([id], [username], [item_id], [sold]) VALUES (24, N'sina', 5, 1)
INSERT [dbo].[user_item] ([id], [username], [item_id], [sold]) VALUES (25, N'sina', 5, 1)
INSERT [dbo].[user_item] ([id], [username], [item_id], [sold]) VALUES (26, N'sina', 5, 1)
INSERT [dbo].[user_item] ([id], [username], [item_id], [sold]) VALUES (27, N'sina', 6, 0)
SET IDENTITY_INSERT [dbo].[user_item] OFF
ALTER TABLE [dbo].[match_log]  WITH CHECK ADD  CONSTRAINT [FK_match_log_user_hero] FOREIGN KEY([killer_username])
REFERENCES [dbo].[user_hero] ([username])
GO
ALTER TABLE [dbo].[match_log] CHECK CONSTRAINT [FK_match_log_user_hero]
GO
ALTER TABLE [dbo].[match_log]  WITH CHECK ADD  CONSTRAINT [FK_match_log_user_hero1] FOREIGN KEY([killed_username])
REFERENCES [dbo].[user_hero] ([username])
GO
ALTER TABLE [dbo].[match_log] CHECK CONSTRAINT [FK_match_log_user_hero1]
GO
ALTER TABLE [dbo].[user_hero]  WITH CHECK ADD  CONSTRAINT [FK_user_hero_hero] FOREIGN KEY([hero_id])
REFERENCES [dbo].[hero] ([id])
GO
ALTER TABLE [dbo].[user_hero] CHECK CONSTRAINT [FK_user_hero_hero]
GO
ALTER TABLE [dbo].[user_item]  WITH CHECK ADD  CONSTRAINT [FK_user_item_item] FOREIGN KEY([item_id])
REFERENCES [dbo].[item] ([id])
GO
ALTER TABLE [dbo].[user_item] CHECK CONSTRAINT [FK_user_item_item]
GO
/****** Object:  StoredProcedure [dbo].[apply_assistances]    Script Date: 1/4/2017 5:32:25 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[apply_assistances] @victim_username varchar(50)
AS
BEGIN	
	BEGIN TRY
	BEGIN TRANSACTION
		UPDATE user_hero
		SET assistance+=1
		WHERE user_hero.username IN (
			SELECT assistant_username 
			FROM assistance
			WHERE victim_username = @victim_username
		)

		DELETE FROM assistance 
		WHERE victim_username = @victim_username 
	COMMIT TRANSACTION
	END TRY
	BEGIN CATCH
		ROLLBACK
	END CATCH
END


GO
/****** Object:  StoredProcedure [dbo].[apply_cyclic_items]    Script Date: 1/4/2017 5:32:25 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[apply_cyclic_items] 
AS
BEGIN
UPDATE user_hero
SET     user_hero.mana += item.cycle_mana,
		user_hero.hp += item.cycle_hp
FROM 
	item , user_item , user_hero 
WHERE 
	item.id= user_item.item_id AND user_hero.username= user_item.username AND item.cyclic=1

END



GO
/****** Object:  StoredProcedure [dbo].[apply_item]    Script Date: 1/4/2017 5:32:25 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[apply_item] @item_id int ,@username varchar(50)
AS
BEGIN
DECLARE @hp_change_val int;
DECLARE @mana_change_val int;
DECLARE @hp_change_per int;
DECLARE @mana_change_per int;
DECLARE @strength_change_val int;
DECLARE @strength_change_per int;
DECLARE @agility_change_val int;
DECLARE @agility_change_per int;
DECLARE @intelligence_change_val int;
DECLARE @intelligence_change_per int;

BEGIN TRY
BEGIN TRANSACTION
	SELECT @hp_change_val = hp,
		   @mana_change_val = mana,
		   @strength_change_val=strength,
		   @strength_change_per=per_strength,
		   @agility_change_val=agility,
		   @agility_change_per=per_agility,
		   @intelligence_change_val=intelligence,
		   @intelligence_change_per=per_intelligence,
		   @hp_change_per = per_hp,
		   @mana_change_per = per_mana
	FROM item
	WHERE id = @item_id

	UPDATE user_hero
	SET hp  += @hp_change_val + hp*@hp_change_per,
		mana += @mana_change_val + mana*@mana_change_per
	WHERE username = @username




	-- check if reach max 
	DECLARE @current_hp int;
	DECLARE @current_mana int;
	DECLARE @base_hp int;
	DECLARE @base_mana int;
	SET @base_hp = dbo.calculate_base_hp(@username)
	SET @base_mana = dbo.calculate_base_mana(@username)
	SELECT @current_hp=hp,@current_mana=mana
	FROM user_hero
	WHERE username=@username
	IF(@current_hp > @base_hp)
		BEGIN
			UPDATE user_hero
			SET hp = @base_hp
			WHERE username=@username
		END
	IF(@current_mana > @base_mana)
		BEGIN
			UPDATE user_hero
			SET mana = @base_mana
			WHERE username=@username
		END

COMMIT TRANSACTION
END TRY
BEGIN CATCH
	ROLLBACK
END CATCH

END



GO
/****** Object:  StoredProcedure [dbo].[apply_uniqueness]    Script Date: 1/4/2017 5:32:25 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[apply_uniqueness] @hero_username varchar(50),@opponent_username varchar(50),@action_type varchar(10),@action_value int,@magic_spell varchar(20) 
AS
BEGIN
	DECLARE @hero_uniq_sp varchar(50);
	SET @hero_uniq_sp = 
						(
							SELECT hero.uniqueness_sp
							FROM hero,user_hero
							WHERE hero.id= user_hero.hero_id AND user_hero.username=@hero_username	);
	EXEC @hero_uniq_sp @hero_username,@opponent_username,@action_type,@action_value,@magic_spell;

END


GO
/****** Object:  StoredProcedure [dbo].[attack]    Script Date: 1/4/2017 5:32:25 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[attack] @attacker_username varchar(50),@defender_username varchar(50)
AS
BEGIN
DECLARE @attacker_damage int;
DECLARE @defender_damage int;
DECLARE @attacker_region int;
DECLARE @is_attacker_killed int;
DECLARE @is_defender_killed int;
DECLARE @time datetime;
DECLARE @is_defender_terrored int;
DECLARE @has_defender_bounce int;

IF(dbo.attack_condition(@attacker_username,@defender_username) = 1)
	BEGIN
		BEGIN TRY
		BEGIN TRANSACTION
			UPDATE user_hero
			SET     experience += 10 *(
										SELECT hero_level
										FROM user_hero_virtual_attributes
										WHERE @defender_username = username
										),
			turn -= 1
			FROM hero,user_hero
			WHERE username = @attacker_username

			SELECT  @is_defender_terrored =is_terrored,  @has_defender_bounce = has_bounce_attack
			FROM user_hero
			WHERE username=@defender_username


			SET @defender_damage = 
									(
										SELECT attack
										FROM user_hero_virtual_attributes
										WHERE username = @attacker_username
									)
			SET @attacker_damage = 
									(
										SELECT 0.02*attack
										FROM user_hero_virtual_attributes
										WHERE username = @defender_username
									)

			IF(@is_defender_terrored=1)
			BEGIN
				SET @attacker_damage = 0;
			END

			IF(@has_defender_bounce=1)
			BEGIN
				SET @attacker_damage = @defender_damage;
				SET @defender_damage = 0;
				UPDATE user_hero
				SET has_bounce_attack=0
				WHERE username=@defender_username
			END

			EXEC wound_user_by_val @defender_username,@defender_damage
			EXEC wound_user_by_val @attacker_username,@attacker_damage
		
			EXEC apply_uniqueness @attacker_username,@defender_username,'attack',@defender_damage,NULL;

			IF(dbo.is_death(@defender_username) = 1)
			BEGIN
				EXEC murder @attacker_username,@defender_username;
				SET @is_defender_killed = 1;
			END
			ELSE
			BEGIN
				EXEC register_assistant @defender_username,@attacker_username
			END

			IF (dbo.is_death(@attacker_username) = 1)
			BEGIN
				EXEC murder @defender_username,@attacker_username;
				SET @is_attacker_killed = 1;
			END
			ELSE
			BEGIN
				EXEC register_assistant @attacker_username,@defender_username
			END				
			SET @attacker_region = 
									(
										SELECT region
										FROM user_hero
										WHERE username = @attacker_username
									)
			SET @time = getdate();
			EXEC log_attack @defender_username,@attacker_username,0,@attacker_damage,@defender_damage,@time,@attacker_region,NULL,@is_attacker_killed,@is_defender_killed
		COMMIT TRANSACTION
		END TRY
		BEGIN CATCH
			ROLLBACK
		END CATCH
		RETURN 1;
	END
	RETURN NULL;
END


GO
/****** Object:  StoredProcedure [dbo].[buy_item]    Script Date: 1/4/2017 5:32:25 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[buy_item] 
@buyer_username varchar(50),
@item_id int
AS
BEGIN

	DECLARE @buyer_current_gold int;
	DECLARE @buyer_level int;
	DECLARE @buyer_region int;
	DECLARE @item_price int;
	DECLARE @item_level int;
	DECLARE @item_region int;
	DECLARE @free_slot int;

	SELECT @buyer_current_gold = gold,
		   @buyer_level = hero_level,
		   @buyer_region =region,
		   @free_slot = free_slot
	FROM user_hero,user_hero_virtual_attributes
	WHERE user_hero.username = user_hero_virtual_attributes.username AND user_hero.username = @buyer_username

	SELECT @item_price = price,
		   @item_level = item_level,
		   @item_region = region 
	FROM item
	WHERE id = @item_id

	IF (@free_slot>0 AND  @buyer_current_gold >= @item_price AND @buyer_level >= @item_level AND @buyer_region = @item_region)
	BEGIN

				UPDATE user_hero
				SET gold -= @item_price,
					free_slot -=1
				WHERE username = @buyer_username

				INSERT INTO user_item (username,item_id,sold)
				VALUES (@buyer_username,@item_id,0);

				EXEC dbo.apply_item @item_id, @buyer_username;
		
		select [ret]=1;
		RETURN ;
	END
	select [ret]=-1;
END



GO
/****** Object:  StoredProcedure [dbo].[change_region]    Script Date: 1/4/2017 5:32:25 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[change_region] @username varchar(50),@dest_region int
AS
BEGIN
	DECLARE @curr_region int;
	DECLARE @gold int;

	SELECT @curr_region=region,@gold=gold 
	FROM user_hero
	WHERE username = @username

	IF(@curr_region = @dest_region OR @gold < 50)
	BEGIN 
		return NULL;
	END

	UPDATE user_hero
	SET region=@dest_region,gold-=50
	WHERE username=@username

	RETURN 1

END


GO
/****** Object:  StoredProcedure [dbo].[get_ally_list]    Script Date: 1/4/2017 5:32:25 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[get_ally_list] @username varchar(50)
AS
BEGIN
	SELECT t2.username
	FROM user_hero as t1 ,user_hero as t2
	WHERE t1.username = @username AND (t1.region !=0 OR t1.team = t2.team )AND t1.region=t2.region AND t1.username !=t2.username
END

GO
/****** Object:  StoredProcedure [dbo].[get_enemy_list]    Script Date: 1/4/2017 5:32:25 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[get_enemy_list] @username varchar(50)
AS
BEGIN
	SELECT t2.username
	FROM user_hero as t1 ,user_hero as t2
	WHERE t1.username = @username AND t2.region !=0 AND t1.team != t2.team AND dbo.attack_condition(t1.username,t2.username)=1 AND t1.username !=t2.username
END

GO
/****** Object:  StoredProcedure [dbo].[get_spell_list]    Script Date: 1/4/2017 5:32:25 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[get_spell_list] @username varchar(50) 
AS
BEGIN

	SELECT spell.name,spell.description,spell.cost,spell.id,spell.apply_sp,spell.hero_level
	FROM spell,user_hero,user_hero_virtual_attributes
	WHERE user_hero.username = user_hero_virtual_attributes.username AND
		  user_hero_virtual_attributes.hero_level >= spell.hero_level AND
		  user_hero.mana >= spell.cost AND user_hero.username = @username
END

GO
/****** Object:  StoredProcedure [dbo].[get_user_info]    Script Date: 1/4/2017 5:32:25 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[get_user_info] @username varchar(50) 
AS
BEGIN
	SELECT t1.username,
		   t3.logo,
		   t1.team,
		   t3.name,
		   t1.gold,
		   t1.full_name,
		   t1.hp,
		   t2.base_hp,
		   t1.mana,
		   t2.base_mana,
		   t2.strength,
		   t2.agility,
		   t2.intelligence,
		   t2.attack,
		   t2.armor,
		   t2.hero_level,
		   t1.experience,
		   t2.rank,
		   t1.region,
		   t1.kills,
		   t1.deaths,
		   t1.assistance,
		   t1.kill_streak,
		   t1.turn
	FROM user_hero as t1,user_hero_virtual_attributes as t2,hero as t3
	WHERE t1.username = t2.username AND t1.username = @username AND t1.hero_id = t3.id
END

GO
/****** Object:  StoredProcedure [dbo].[get_user_items]    Script Date: 1/4/2017 5:32:25 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[get_user_items] @username varchar(50)
AS
BEGIN
	SELECT *
	FROM user_item,item
	WHERE username = @username AND item_id = item.id AND sold !=1
END

GO
/****** Object:  StoredProcedure [dbo].[give_gold]    Script Date: 1/4/2017 5:32:25 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[give_gold] 
AS
BEGIN
/*
ptype
	agility 0
	strength 1
	intelligence 2
*/
UPDATE user_hero
SET     gold += va.hero_level * 70 
FROM 
	user_hero uh, user_hero_virtual_attributes va
WHERE 
	uh.username = va.username AND uh.region!=0
END



GO
/****** Object:  StoredProcedure [dbo].[give_turn]    Script Date: 1/4/2017 5:32:25 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[give_turn] 
AS
BEGIN
/*
ptype
	agility 0
	strength 1
	intelligence 2
*/
UPDATE user_hero
SET     turn += 
					(
						CASE
							WHEN h.ptype  = 0 THEN dbo.minimum(va.agility/30 + 1,6)
							WHEN h.ptype != 0 THEN dbo.minimum(va.agility/40 + 1,4)
						END
					)
FROM 
	hero h, user_hero uh, user_hero_virtual_attributes va
WHERE 
	h.id = uh.hero_id AND uh.username = va.username AND uh.region!=0

UPDATE user_hero
SET     turn = 
					(
						CASE
							WHEN h.ptype  = 0 THEN dbo.minimum(135,uh.turn)
							WHEN h.ptype != 0 THEN dbo.minimum(100,uh.turn)
						END
					)
FROM 
	hero h, user_hero uh
WHERE 
	h.id = uh.hero_id 


END



GO
/****** Object:  StoredProcedure [dbo].[heal]    Script Date: 1/4/2017 5:32:25 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/*
ptype
	agility 0
	strength 1
	intelligence 2
*/
CREATE PROCEDURE [dbo].[heal] @healer_username varchar(50), @healing_username varchar(50)
AS
BEGIN
	DECLARE @healer_turn int;
	DECLARE @healing_region int;
	DECLARE @healer_team int;
	DECLARE @healing_team int;
	DECLARE @healer_mana int;
	DECLARE @healer_intelligence int;
	DECLARE @heal_cost int;

	SELECT @heal_cost = value
	FROM config
	WHERE name = 'heal_cost'

	SELECT	@healer_turn=turn,
			@healer_team = team,
			@healer_mana = mana,
			@healer_intelligence = user_hero_virtual_attributes.intelligence
	FROM user_hero,user_hero_virtual_attributes
	WHERE user_hero.username = user_hero_virtual_attributes.username AND user_hero.username = @healer_username

	SELECT	@healing_team = team,
			@healing_region = region
	FROM	user_hero
	WHERE	user_hero.username = @healing_username

	IF(@healer_mana >= @heal_cost AND @healer_turn>0 AND (@healing_region!=0 OR (@healer_team = @healing_team)))
	BEGIN
		UPDATE user_hero
		SET     experience += 
							(
								CASE
									WHEN ptype = 0 OR ptype = 1 THEN 1
									WHEN ptype = 2 THEN 4
								END
							),
				turn-=1,
				mana-=@heal_cost
		FROM hero , user_hero
		WHERE username = @healer_username AND id = hero_id
		exec dbo.heal_user_by_val @healing_username,@healer_intelligence;
		EXEC apply_uniqueness @healer_username,@healing_username,'heal',@healer_intelligence,NULL;
		select [ret]=1;
		RETURN;
	END
	select [ret]=-1;
END



GO
/****** Object:  StoredProcedure [dbo].[heal_user_by_val]    Script Date: 1/4/2017 5:32:25 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[heal_user_by_val] @username varchar(50) ,@hp_val int
AS
BEGIN
	UPDATE user_hero
	SET hp += @hp_val
	WHERE username = @username

	DECLARE @current_hp int;
	DECLARE @base_hp int;

	SET @base_hp = dbo.calculate_base_hp(@username)

	SELECT @current_hp=hp
	FROM user_hero
	WHERE username=@username

	IF(@current_hp > @base_hp)
	BEGIN
		UPDATE user_hero
		SET hp = @base_hp
		WHERE username=@username
	END
END



GO
/****** Object:  StoredProcedure [dbo].[log_attack]    Script Date: 1/4/2017 5:32:25 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[log_attack] @defender_username varchar(50),@attacker_username varchar(50),@attack_type int,@attacker_damage int,@defender_damage int,@time datetime ,@region int,@spell_id int,@is_attacker_killed int,@is_defender_killed int
AS
BEGIN
	INSERT INTO attack_log(defender_username,attacker_username,attack_type,attacker_damage,defender_damage,time,region,spell_id,is_attacker_killed,is_defender_killed) 
	VALUES				(@defender_username,@attacker_username,@attack_type,@attacker_damage,@defender_damage,@time,@region,@spell_id,@is_attacker_killed,@is_defender_killed) ;
END



GO
/****** Object:  StoredProcedure [dbo].[log_kill]    Script Date: 1/4/2017 5:32:25 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[log_kill] @killer_username varchar(50),@victim_username varchar(50),@region int,@time datetime 
AS
BEGIN
	INSERT INTO kill_log(killer_username,victim_username,region,time) 
	VALUES				(@killer_username,@victim_username,@region,@time) ;
END



GO
/****** Object:  StoredProcedure [dbo].[login]    Script Date: 1/4/2017 5:32:25 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[login] @username varchar(50),@password varchar(50)
AS
BEGIN
	SELECT * 
	FROM user_hero
	WHERE username = @username AND password=@password
END

GO
/****** Object:  StoredProcedure [dbo].[magic]    Script Date: 1/4/2017 5:32:25 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[magic]
@doer_username varchar(50),
@defender_username varchar(50),
@spell_id int
AS
BEGIN

	DECLARE @doer_mana int;
	DECLARE @doer_level int;
	DECLARE @spell_cost int;
	DECLARE @spell_level int;
	DECLARE @spell_ret int;
	DECLARE @doer_region int;
	DECLARE @is_defender_killed int;
	DECLARE @time datetime;
	
	SELECT @spell_cost = cost,@spell_level = hero_level
	FROM spell
	WHERE @spell_id = id

	SELECT	@doer_mana = mana,@doer_level = hero_level
	FROM user_hero,user_hero_virtual_attributes
	WHERE user_hero.username = user_hero_virtual_attributes.username AND user_hero.username = @doer_username

	IF(@doer_mana >= @spell_cost AND @doer_level >=@spell_level AND dbo.attack_condition(@doer_username,@defender_username) = 1)
	BEGIN
		BEGIN TRANSACTION;
		UPDATE user_hero
		SET     experience += 
							(	
								CASE
									WHEN ptype = 0 OR ptype =1 THEN 10
									WHEN ptype = 2 THEN 10*
															(
																SELECT hero_level
																FROM user_hero_virtual_attributes
																WHERE username = @defender_username
															)
								END	
							),
				mana -= @spell_cost,
				turn -= 1
		FROM hero,user_hero
		WHERE username = @doer_username AND id = hero_id

		DECLARE @spell_sp varchar(200);
		SET @spell_sp = 
						(
							SELECT apply_sp
							FROM spell
							WHERE id = @spell_id
						)


		exec @spell_ret = @spell_sp @doer_username,@defender_username;
		IF (@spell_ret = -1)
		BEGIN
			ROLLBACK;
			RETURN NULL
		END 

		IF (dbo.is_death(@defender_username) = 1)
		BEGIN
			EXEC murder @doer_username,@defender_username;
			SET @is_defender_killed = 1;
		END
		ELSE IF(@defender_username!=@doer_username)
		BEGIN
			EXEC register_assistant @defender_username,@doer_username;
		END				

		SET @doer_region = 
								(
									SELECT region
									FROM user_hero
									WHERE username = @doer_username
								)
		SET @time = getdate();
		EXEC log_attack @defender_username,@doer_username,1,NULL,NULL,@time,@doer_region,@spell_id,0,@is_defender_killed
		RETURN 1;
	END
	RETURN NULL;
END



GO
/****** Object:  StoredProcedure [dbo].[murder]    Script Date: 1/4/2017 5:32:25 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[murder] @killer_username varchar(50),@killed_username varchar(50)
AS
BEGIN

DECLARE @change_gold_value int;
DECLARE @time datetime;
DECLARE @killer_region int;

SET @change_gold_value = dbo.minimum(400,0.1*( SELECT t1.gold FROM user_hero AS t1 WHERE t1.username = @killed_username))

UPDATE user_hero
SET     gold += @change_gold_value,
		kill_streak +=1,
		kills +=1,
		experience += 
					(
						SELECT value
						FROM config
						WHERE name = 'kill_exp'
					)

WHERE username = @killer_username

UPDATE user_hero
SET deaths +=1,
	kill_streak = 0,
	gold -= @change_gold_value
WHERE username = @killed_username

EXEC refill_hp @killed_username;
EXEC refill_mana @killed_username;
EXEC apply_assistances @killed_username

SET @killer_region = 
					(
						SELECT region
						FROM user_hero
						WHERE username = @killer_username
					)
SET @time = getdate();
EXEC log_kill @killer_username,@killed_username,@killer_region,@time
END



GO
/****** Object:  StoredProcedure [dbo].[refill_hp]    Script Date: 1/4/2017 5:32:25 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[refill_hp] @username varchar(50)
AS
BEGIN
	UPDATE user_hero
	SET hp = dbo.calculate_base_hp(@username)
	WHERE username = @username
END



GO
/****** Object:  StoredProcedure [dbo].[refill_mana]    Script Date: 1/4/2017 5:32:25 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[refill_mana] @username varchar(50)
AS
BEGIN
	UPDATE user_hero
	SET mana = dbo.calculate_base_mana(@username)
	WHERE username = @username
END



GO
/****** Object:  StoredProcedure [dbo].[register_assistant]    Script Date: 1/4/2017 5:32:25 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[register_assistant] @victim_username varchar(50),@assistant_username varchar(50)
AS
BEGIN
	INSERT INTO assistant (victim_username,assistant_username)
	VALUES(@victim_username,@assistant_username);
END


GO
/****** Object:  StoredProcedure [dbo].[register_user]    Script Date: 1/4/2017 5:32:25 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[register_user] @username varchar(50) ,@password varchar(50),@full_name varchar(50),@city varchar(50),@email varchar(50),@country varchar(50),@age int,@team int,@hero_id int
AS
BEGIN
	INSERT INTO user_hero (username , password, full_name, city, email, country, age,experience,region,turn,kill_streak,kills,deaths,assistance, team, gold,hp,mana, hero_id,free_slot,is_terrored,has_bounce_attack)
	VALUES                (@username,@password,@full_name,@city,@email,@country,@age,1000      ,2     ,0   ,0          ,0    ,0     ,0         ,@team,100,0 ,0   ,@hero_id,0,0,0);
	exec dbo.refill_hp @username;
	exec dbo.refill_mana @username;
	exec dbo.set_base_attr @username;
END



GO
/****** Object:  StoredProcedure [dbo].[sell_item]    Script Date: 1/4/2017 5:32:25 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[sell_item]
@seller_username varchar(50),
@item_id int
AS
BEGIN

UPDATE user_hero
SET gold += (
			SELECT price/2
			FROM item
			WHERE id = @item_id
			),
	free_slot +=1
WHERE username = @seller_username
/* delete item from table user_item */
UPDATE user_item 
SET sold = 1
WHERE username = @seller_username AND item_id=@item_id

END



GO
/****** Object:  StoredProcedure [dbo].[set_base_attr]    Script Date: 1/4/2017 5:32:25 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[set_base_attr] @username varchar(50)
AS
BEGIN
	UPDATE user_hero
	SET free_slot = (
						SELECT value
						FROM config
						WHERE name = 'max_slot'
					)
	WHERE username = @username
END



GO
/****** Object:  StoredProcedure [dbo].[spell_bounce_attack]    Script Date: 1/4/2017 5:32:25 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================

CREATE PROCEDURE [dbo].[spell_bounce_attack] @attacker_username varchar(50),@defender_username varchar(50)
AS
BEGIN
	UPDATE user_hero
	SET has_bounce_attack=1
	WHERE username=@attacker_username

	EXEC apply_uniqueness @attacker_username,@defender_username,'magic',NULL,'Bounce Attack' ;
	RETURN 1;
END



GO
/****** Object:  StoredProcedure [dbo].[spell_brand_sap]    Script Date: 1/4/2017 5:32:25 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================

CREATE PROCEDURE [dbo].[spell_brand_sap] @attacker_username varchar(50),@defender_username varchar(50)
AS
BEGIN
	DECLARE @attacker_hero_type int;

	SELECT @attacker_hero_type=ptype
	FROM user_hero,hero
	WHERE @attacker_username=username AND hero_id = id

	DECLARE @spell_ptype int;
	SET @spell_ptype= 2;

	IF (@attacker_hero_type=@spell_ptype)
	BEGIN
		DECLARE @hp_change_val int;
		SET @hp_change_val =
		 					(
								SELECT intelligence*0.02 FROM user_hero_virtual_attributes WHERE username = @attacker_username
							)
		EXEC dbo.wound_user_by_val @defender_username,@hp_change_val;		
		EXEC heal_user_by_val @attacker_username,@hp_change_val;
		EXEC apply_uniqueness @attacker_username,@defender_username,'magic',@hp_change_val,'Brand Sap';
		RETURN 1
	END
	RETURN -1
END



GO
/****** Object:  StoredProcedure [dbo].[spell_death_coil]    Script Date: 1/4/2017 5:32:25 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================

CREATE PROCEDURE [dbo].[spell_death_coil] @attacker_username varchar(50),@defender_username varchar(50)
AS
BEGIN
	DECLARE @hp_change_val int;
	SET @hp_change_val =
		 				(
							SELECT intelligence*0.2 FROM user_hero_virtual_attributes WHERE username = @attacker_username
						)
	exec dbo.wound_user_by_val @defender_username,@hp_change_val;
	EXEC apply_uniqueness @attacker_username,@defender_username,'magic',@hp_change_val,'Death Coil';
	RETURN 1
END



GO
/****** Object:  StoredProcedure [dbo].[spell_finger_of_death]    Script Date: 1/4/2017 5:32:25 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================

CREATE PROCEDURE [dbo].[spell_finger_of_death] @attacker_username varchar(50),@defender_username varchar(50)
AS
BEGIN
	DECLARE @attacker_hero_type int;

	SELECT @attacker_hero_type=ptype
	FROM user_hero,hero
	WHERE @attacker_username=username AND hero_id = id

	DECLARE @spell_ptype int;
	SET @spell_ptype= 2;
	
	IF (@attacker_hero_type = @spell_ptype)
	BEGIN
		DECLARE @hp_change_val int;
		SET @hp_change_val =
		 					(
								SELECT intelligence*0.4 FROM user_hero_virtual_attributes WHERE username = @attacker_username
							)
		exec dbo.wound_user_by_val @defender_username,@hp_change_val;
		EXEC apply_uniqueness @attacker_username,@defender_username,'magic',@hp_change_val,'Finger of Death';
		RETURN 1
	END
	RETURN -1
END



GO
/****** Object:  StoredProcedure [dbo].[spell_gold_hunger]    Script Date: 1/4/2017 5:32:25 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================

CREATE PROCEDURE [dbo].[spell_gold_hunger] @attacker_username varchar(50),@defender_username varchar(50)
AS
BEGIN
	DECLARE @attacker_hero_type int;

	SELECT @attacker_hero_type=ptype
	FROM user_hero,hero
	WHERE @attacker_username=username AND hero_id = id

	DECLARE @spell_ptype int;
	SET @spell_ptype= 2;
	
	IF (@attacker_hero_type=@spell_ptype)
	BEGIN
		UPDATE user_hero
		SET gold -= 0.5*gold
		WHERE username=@defender_username

		EXEC apply_uniqueness @attacker_username,@defender_username,'magic',NULL,'Gold Hunger' ;
		RETURN 1
	END
	RETURN -1
END



GO
/****** Object:  StoredProcedure [dbo].[spell_gold_spy]    Script Date: 1/4/2017 5:32:25 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[spell_gold_spy] @attacker_username varchar(50),@defender_username varchar(50)
AS
BEGIN	
	DECLARE @enemy_gold int;
	SET @enemy_gold	=
					(
						SELECT gold FROM user_hero WHERE username = @defender_username
					)
	EXEC apply_uniqueness @attacker_username,@defender_username,'magic',NULL,'Gold Spy' ;
	RETURN @enemy_gold;

END



GO
/****** Object:  StoredProcedure [dbo].[spell_gush]    Script Date: 1/4/2017 5:32:25 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================

CREATE PROCEDURE [dbo].[spell_gush] @attacker_username varchar(50),@defender_username varchar(50)
AS
BEGIN
	DECLARE @attacker_hero_type int;

	SELECT @attacker_hero_type=ptype
	FROM user_hero,hero
	WHERE @attacker_username=username AND hero_id = id

	DECLARE @spell_ptype int;
	SET @spell_ptype= 2;
	
	IF (@attacker_hero_type=@spell_ptype)
	BEGIN
		DECLARE @hp_change_val int;
		SET @hp_change_val =
		 					(
								SELECT intelligence*0.1 FROM user_hero_virtual_attributes WHERE username = @attacker_username
							)
		exec dbo.wound_user_by_val @defender_username,@hp_change_val;
		EXEC apply_uniqueness @attacker_username,@defender_username,'magic',@hp_change_val,'Gush' ;
		RETURN 1
	END
	RETURN -1
END



GO
/****** Object:  StoredProcedure [dbo].[spell_hero_spy]    Script Date: 1/4/2017 5:32:25 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[spell_hero_spy] @attacker_username varchar(50),@defender_username varchar(50)
AS
BEGIN
	EXEC apply_uniqueness @attacker_username,@defender_username,'magic',NULL,'Hero Spy' ;
	RETURN	SELECT v1.agility,
					v1.strength,
					v1.intelligence,
					v1.armor,
					v1.base_mana,
					v1.base_hp,
					t2.ptype,
					t2.name 
			FROM user_hero AS t1,hero AS t2,dbo.user_hero_virtual_attributes AS v1
			WHERE t1.username=@defender_username AND t1.hero_id=t2.id AND v1.username = t1.username
END



GO
/****** Object:  StoredProcedure [dbo].[spell_lightning_bolt]    Script Date: 1/4/2017 5:32:25 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[spell_lightning_bolt] @attacker_username varchar(50),@defender_username varchar(50)
--The basic magic attack.
AS
BEGIN
	DECLARE @hp_change_val int;
	SET @hp_change_val =
		 				(
							SELECT intelligence*0.05 FROM user_hero_virtual_attributes WHERE username = @attacker_username
						)
	EXEC dbo.wound_user_by_val @defender_username,@hp_change_val;
	EXEC apply_uniqueness @attacker_username,@defender_username,'magic',@hp_change_val,'Lightning Bolt' ;
	RETURN 1
	
END



GO
/****** Object:  StoredProcedure [dbo].[spell_mana_burn]    Script Date: 1/4/2017 5:32:25 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================



CREATE PROCEDURE [dbo].[spell_mana_burn] @attacker_username varchar(50),@defender_username varchar(50)
AS
BEGIN
	UPDATE user_hero
	SET mana -= 0.15*mana
	WHERE username=@defender_username
	EXEC apply_uniqueness @attacker_username,@defender_username,'magic',NULL,'Mana Burn' ;
	RETURN 1

END



GO
/****** Object:  StoredProcedure [dbo].[spell_sunder]    Script Date: 1/4/2017 5:32:25 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================

CREATE PROCEDURE [dbo].[spell_sunder] @attacker_username varchar(50),@defender_username varchar(50)
AS
BEGIN
	DECLARE @attacker_hero_type int;

	SELECT @attacker_hero_type=ptype
	FROM user_hero,hero
	WHERE @attacker_username=username AND hero_id = id

	DECLARE @spell_ptype int;
	SET @spell_ptype= 2;
	
	IF ( @attacker_hero_type = @spell_ptype)
	BEGIN
		DECLARE @enemy_hp int;
		DECLARE @enemy_mana int;
		DECLARE @my_hp int;
		DECLARE @my_mana int;
		DECLARE @my_base_hp int;
		DECLARE @my_base_mana int;
		DECLARE @enemy_base_hp int;
		DECLARE @enemy_base_mana int;

		SET @my_base_hp = dbo.calculate_base_hp(@attacker_username)
		SET @my_base_mana = dbo.calculate_base_mana(@attacker_username)
		SET @enemy_base_hp = dbo.calculate_base_hp(@defender_username)
		SET @enemy_base_mana = dbo.calculate_base_mana(@defender_username)

		SELECT @enemy_hp = hp,@enemy_mana=mana
		FROM user_hero
		WHERE username = @defender_username

		SELECT @my_hp =hp ,@my_mana=mana
		FROM user_hero
		WHERE username = @attacker_username

		UPDATE user_hero
		SET hp =(
					CASE
						WHEN @my_hp<=@enemy_base_hp THEN @my_hp
						WHEN @my_hp>@enemy_base_hp THEN @enemy_base_hp
					END
				),
			mana=(
					CASE
						WHEN @my_mana<=@enemy_base_mana THEN @my_mana
						WHEN @my_mana>@enemy_base_mana THEN @enemy_base_mana
					END
				)
		WHERE username=@defender_username

		UPDATE user_hero
		SET hp =(
					CASE
						WHEN @enemy_hp<=@my_base_hp THEN @enemy_hp
						WHEN @enemy_hp>@my_base_hp THEN @my_base_hp
					END
				),
			mana=(
					CASE
						WHEN @enemy_mana<=@my_base_mana THEN @enemy_mana
						WHEN @enemy_mana>@my_base_mana THEN @my_base_mana
					END
				)
		WHERE username=@attacker_username

		EXEC apply_uniqueness @attacker_username,@defender_username,'magic',NULL,'Sunder' ;
		RETURN 1
	END
	RETURN -1
END



GO
/****** Object:  StoredProcedure [dbo].[spell_sunder_health]    Script Date: 1/4/2017 5:32:25 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================

CREATE PROCEDURE [dbo].[spell_sunder_health] @attacker_username varchar(50),@defender_username varchar(50)
AS
BEGIN
	DECLARE @defender_hero_type int;
	DECLARE @attacker_hero varchar(50);

	SELECT @defender_hero_type=ptype
	FROM user_hero,hero
	WHERE @defender_username = username AND hero_id = id
		
	SELECT @attacker_hero=hero.name
	FROM user_hero,hero
	WHERE @attacker_username = username AND hero_id = id

	DECLARE @spell_ptype int;
	SET @spell_ptype= 2;
	
	--Available to Lina Inverse and Holy Knight only
	--Does not work against Intelligence based heroes
	IF (@defender_hero_type != @spell_ptype AND (@attacker_hero='Holy Knight' OR @attacker_hero='Lina Inverse'))
	BEGIN
		DECLARE @enemy_hp int;
		DECLARE @my_hp int;
		DECLARE @my_base_hp int;
		DECLARE @enemy_base_hp int;

		SELECT @enemy_hp = hp
		FROM user_hero
		WHERE username = @defender_username

		SELECT @my_hp =hp
		FROM user_hero
		WHERE username = @attacker_username


		UPDATE user_hero
		SET hp =(
					CASE
						WHEN @my_hp<=@enemy_base_hp THEN @my_hp
						WHEN @my_hp>@enemy_base_hp THEN @enemy_base_hp
					END
				)
		WHERE username=@defender_username
		
		UPDATE user_hero
		SET hp =(
					CASE
						WHEN @enemy_hp<=@my_base_hp THEN @enemy_hp
						WHEN @enemy_hp>@my_base_hp THEN @my_base_hp
					END
				)
		WHERE username=@attacker_username

		EXEC apply_uniqueness @attacker_username,@defender_username,'magic',NULL,'Sunder Health' ;
		RETURN 1
	END
	RETURN -1
END



GO
/****** Object:  StoredProcedure [dbo].[spell_terror]    Script Date: 1/4/2017 5:32:25 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================

CREATE PROCEDURE [dbo].[spell_terror] @attacker_username varchar(50),@defender_username varchar(50)
AS
BEGIN
	DECLARE @attacker_hero_type int;

	SELECT @attacker_hero_type=ptype
	FROM user_hero,hero
	WHERE @attacker_username=username AND hero_id = id

	DECLARE @spell_ptype int;
	SET @spell_ptype= 0;
	
	IF (@attacker_hero_type = @spell_ptype)
	BEGIN
		UPDATE user_hero
		SET is_terrored=1
		WHERE username=@defender_username
		
		EXEC apply_uniqueness @attacker_username,@defender_username,'magic',NULL,'Terror' ;
		RETURN 0;
	END
	RETURN -1;
END



GO
/****** Object:  StoredProcedure [dbo].[turn]    Script Date: 1/4/2017 5:32:25 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[turn] 
AS
BEGIN	
	DELETE FROM assistance;
	EXEC give_turn;
	EXEC give_gold;
	EXEC apply_cyclic_items;

	UPDATE user_hero
	SET is_terrored=0
	WHERE is_terrored=1
END


GO
/****** Object:  StoredProcedure [dbo].[uniq_holy_knight]    Script Date: 1/4/2017 5:32:25 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================

CREATE PROCEDURE [dbo].[uniq_holy_knight] @hero_username varchar(50),@opponent_username varchar(50),@action_type varchar(10),@action_value int,@magic_spell varchar(20) 
AS
BEGIN
	IF(@action_type='heal')
	BEGIN	
		DECLARE @extra_heal int;
		SET @extra_heal = (CONVERT(INT,ROUND(3*RAND(),0)) + 1) * 0.1 * @action_value;
		exec dbo.heal_user_by_val @opponent_username,@extra_heal;	
	END
	ELSE IF(@action_type='magic')
	BEGIN
		IF(@magic_spell='Lightning Bolt' OR @magic_spell='Gush' OR @magic_spell='Death Coil'
		OR @magic_spell='Brand Sap' OR @magic_spell='Finger of Death')
		BEGIN
			DECLARE @extra_damage int;
			SET @extra_damage =  0.15 * @action_value;
			exec dbo.wound_user_by_val @opponent_username,@extra_damage;	
		END
	END
END


GO
/****** Object:  StoredProcedure [dbo].[uniq_pendaren_battlemaster]    Script Date: 1/4/2017 5:32:25 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================

CREATE PROCEDURE [dbo].[uniq_pendaren_battlemaster] @hero_username varchar(50),@opponent_username varchar(50),@action_type varchar(10),@action_value int,@magic_spell varchar(20) 
AS
BEGIN
	IF(@action_type='attack')
	BEGIN	
		DECLARE @extra_damage int;
		SET @extra_damage = CONVERT(INT,ROUND(3*RAND(),0)) * @action_value;
		exec dbo.wound_user_by_val @opponent_username,@extra_damage;	
	END
END


GO
/****** Object:  StoredProcedure [dbo].[wound_user_by_val]    Script Date: 1/4/2017 5:32:25 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[wound_user_by_val] @username varchar(50) , @val int 
AS
BEGIN
		UPDATE user_hero
		SET hp -= @val
		WHERE username=@username
END



GO
EXEC sys.sp_addextendedproperty @name=N'MS_DiagramPane1', @value=N'[0E232FF0-B466-11cf-A24F-00AA00A3EFFF, 1.00]
Begin DesignProperties = 
   Begin PaneConfigurations = 
      Begin PaneConfiguration = 0
         NumPanes = 4
         Configuration = "(H (1[41] 4[26] 2[17] 3) )"
      End
      Begin PaneConfiguration = 1
         NumPanes = 3
         Configuration = "(H (1 [50] 4 [25] 3))"
      End
      Begin PaneConfiguration = 2
         NumPanes = 3
         Configuration = "(H (1 [50] 2 [25] 3))"
      End
      Begin PaneConfiguration = 3
         NumPanes = 3
         Configuration = "(H (4 [30] 2 [40] 3))"
      End
      Begin PaneConfiguration = 4
         NumPanes = 2
         Configuration = "(H (1 [56] 3))"
      End
      Begin PaneConfiguration = 5
         NumPanes = 2
         Configuration = "(H (2 [66] 3))"
      End
      Begin PaneConfiguration = 6
         NumPanes = 2
         Configuration = "(H (4 [50] 3))"
      End
      Begin PaneConfiguration = 7
         NumPanes = 1
         Configuration = "(V (3))"
      End
      Begin PaneConfiguration = 8
         NumPanes = 3
         Configuration = "(H (1[56] 4[18] 2) )"
      End
      Begin PaneConfiguration = 9
         NumPanes = 2
         Configuration = "(H (1 [75] 4))"
      End
      Begin PaneConfiguration = 10
         NumPanes = 2
         Configuration = "(H (1[66] 2) )"
      End
      Begin PaneConfiguration = 11
         NumPanes = 2
         Configuration = "(H (4 [60] 2))"
      End
      Begin PaneConfiguration = 12
         NumPanes = 1
         Configuration = "(H (1) )"
      End
      Begin PaneConfiguration = 13
         NumPanes = 1
         Configuration = "(V (4))"
      End
      Begin PaneConfiguration = 14
         NumPanes = 1
         Configuration = "(V (2))"
      End
      ActivePaneConfig = 0
   End
   Begin DiagramPane = 
      Begin Origin = 
         Top = 0
         Left = 0
      End
      Begin Tables = 
         Begin Table = "t1"
            Begin Extent = 
               Top = 6
               Left = 38
               Bottom = 136
               Right = 208
            End
            DisplayFlags = 280
            TopColumn = 0
         End
      End
   End
   Begin SQLPane = 
   End
   Begin DataPane = 
      Begin ParameterDefaults = ""
      End
   End
   Begin CriteriaPane = 
      Begin ColumnWidths = 11
         Column = 1440
         Alias = 900
         Table = 1170
         Output = 1275
         Append = 1400
         NewValue = 1170
         SortType = 1350
         SortOrder = 1410
         GroupBy = 1350
         Filter = 1350
         Or = 1350
         Or = 1350
         Or = 1350
      End
   End
End
' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'VIEW',@level1name=N'user_hero_virtual_attributes'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_DiagramPaneCount', @value=1 , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'VIEW',@level1name=N'user_hero_virtual_attributes'
GO
USE [master]
GO
ALTER DATABASE [dotaweb] SET  READ_WRITE 
GO
