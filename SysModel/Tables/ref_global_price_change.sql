USE [Configurateur]
GO

/****** Object:  Table [dbo].[ref_global_price_change]    Script Date: 2026-04-20 10:23:06 AM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [dbo].[ref_global_price_change](
	[UID] [int] IDENTITY(1,1) NOT NULL,
	[from_table] [nvarchar](50) NULL,
	[from_column] [nvarchar](50) NULL,
	[from_price] [decimal](18, 4) NULL,
	[date_change] [datetime] NULL,
	[from_uid] [int] NULL,
	[price_id] [nvarchar](50) NULL
) ON [PRIMARY]
GO

