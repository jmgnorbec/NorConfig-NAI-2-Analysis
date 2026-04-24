USE [Configurateur]
GO

/****** Object:  Table [dbo].[trx_transport_item]    Script Date: 2026-04-20 11:40:04 AM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [dbo].[trx_transport_item](
	[uid] [int] IDENTITY(1,1) NOT NULL,
	[VBID] [int] NULL,
	[Pal] [int] NULL,
	[ID] [int] NULL,
	[GroupNo] [int] NULL,
	[Item] [nvarchar](250) NULL,
	[Type] [nvarchar](250) NULL,
	[Long] [decimal](18, 4) NULL,
	[Larg] [decimal](18, 4) NULL,
	[Epai] [decimal](18, 4) NULL,
	[Poids] [decimal](18, 4) NULL,
	[trx_groupe_uid] [int] NULL,
 CONSTRAINT [PK_trx_transport_item] PRIMARY KEY CLUSTERED 
(
	[uid] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO

