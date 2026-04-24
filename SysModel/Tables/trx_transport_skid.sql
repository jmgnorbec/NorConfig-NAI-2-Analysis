USE [Configurateur]
GO

/****** Object:  Table [dbo].[trx_transport_skid]    Script Date: 2026-04-20 11:40:30 AM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [dbo].[trx_transport_skid](
	[uid] [int] IDENTITY(1,1) NOT NULL,
	[ID] [int] NULL,
	[Palette] [int] NULL,
	[GroupNo] [int] NULL,
	[Longueur] [decimal](18, 4) NULL,
	[Largeur] [decimal](18, 4) NULL,
	[Hauteur] [decimal](18, 4) NULL,
	[Type] [nvarchar](250) NULL,
	[poid_cost] [decimal](18, 4) NULL,
	[notes] [nvarchar](500) NULL,
	[pi3_reel] [decimal](18, 4) NULL,
	[pi3_full] [decimal](18, 4) NULL,
 CONSTRAINT [PK_trx_transport_skid] PRIMARY KEY CLUSTERED 
(
	[uid] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO

