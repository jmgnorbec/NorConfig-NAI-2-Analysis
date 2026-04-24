USE [Configurateur]
GO

/****** Object:  Table [dbo].[sys_pricing]    Script Date: 2026-04-20 10:37:16 AM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [dbo].[sys_pricing](
	[UID] [int] IDENTITY(1,1) NOT FOR REPLICATION NOT NULL,
	[line] [nvarchar](128) NULL,
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
	[independant_group_no_incr] [int] NULL,
	[independant_comment] [nvarchar](max) NULL,
 CONSTRAINT [sys_pricing_PK] PRIMARY KEY CLUSTERED 
(
	[UID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO

ALTER TABLE [dbo].[sys_pricing] ADD  CONSTRAINT [DF_sys_pricing_own_line]  DEFAULT ((0)) FOR [independant_line]
GO

EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'When true will generate it''s own line in epicor' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'sys_pricing', @level2type=N'COLUMN',@level2name=N'independant_line'
GO

