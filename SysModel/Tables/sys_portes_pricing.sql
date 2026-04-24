USE [Configurateur]
GO

/****** Object:  Table [dbo].[sys_portes_pricing]    Script Date: 2026-04-20 10:36:50 AM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [dbo].[sys_portes_pricing](
	[UID] [int] IDENTITY(1,1) NOT FOR REPLICATION NOT NULL,
	[porte] [nvarchar](50) NULL,
	[application] [nvarchar](50) NULL,
	[condition] [nvarchar](150) NULL,
	[prix_vendant] [decimal](18, 4) NULL,
	[prix_coutant] [decimal](18, 4) NULL,
	[markup] [decimal](18, 4) NULL,
	[ancien_code] [nvarchar](60) NULL,
	[old_desc] [nvarchar](250) NULL,
	[old_vendant] [decimal](18, 4) NULL,
	[comment_finance] [nvarchar](250) NULL,
	[cou_mod] [decimal](18, 4) NULL,
	[cou_fgf] [decimal](18, 4) NULL,
 CONSTRAINT [sys_portes_pricing_PK] PRIMARY KEY CLUSTERED 
(
	[UID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO

