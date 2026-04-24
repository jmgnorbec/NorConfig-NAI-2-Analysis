USE [Configurateur]
GO

/****** Object:  Table [dbo].[trx_pricing]    Script Date: 2026-04-20 11:38:18 AM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [dbo].[trx_pricing](
	[UID] [int] IDENTITY(1,1) NOT FOR REPLICATION NOT NULL,
	[sys_pricing_UID] [int] NULL,
	[for_table] [nvarchar](128) NULL,
	[name] [nvarchar](50) NULL,
	[price_table] [nvarchar](128) NULL,
	[price_field] [nvarchar](128) NULL,
	[qty] [nvarchar](max) NULL,
	[comment] [nvarchar](max) NULL,
	[qty_table] [nvarchar](128) NULL,
	[price_extra] [nvarchar](128) NULL,
	[price_min] [nvarchar](128) NULL,
	[price_extra_per_qty] [nvarchar](128) NULL,
	[qty_condition] [nvarchar](128) NULL,
	[independant_line] [bit] NULL,
	[item_qty] [nvarchar](128) NULL,
	[item_price] [nvarchar](900) NULL,
	[price_per] [nvarchar](50) NULL,
	[prix_extra] [nvarchar](128) NULL,
	[prix_extra_per_qty] [nvarchar](128) NULL,
	[final_price] [float] NULL,
	[final_price2] [nvarchar](128) NULL,
	[item_desc] [nvarchar](max) NULL,
	[min_final_price] [nvarchar](128) NULL,
	[partnum] [nvarchar](50) NULL,
	[for_uid] [int] NULL,
	[independant_group_no_incr] [int] NULL,
	[coutant] [decimal](18, 4) NULL,
	[coutant_mod] [decimal](18, 4) NULL,
	[coutant_fgf] [decimal](18, 4) NULL,
	[independant_comment] [nvarchar](max) NULL,
 CONSTRAINT [trx_pricing_PK] PRIMARY KEY CLUSTERED 
(
	[UID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO

ALTER TABLE [dbo].[trx_pricing] ADD  CONSTRAINT [DF_trx_pricing_own_line]  DEFAULT ((0)) FOR [independant_line]
GO

