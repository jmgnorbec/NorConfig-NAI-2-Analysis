USE [Configurateur]
GO

/****** Object:  Table [dbo].[trx_room]    Script Date: 2026-04-20 11:39:41 AM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [dbo].[trx_room](
	[UID] [int] IDENTITY(1000000,1) NOT NULL,
	[trx_modulr_group_uid] [int] NOT NULL,
	[trx_chambre_uid] [int] NULL,
	[seq_id] [int] NOT NULL,
 CONSTRAINT [PK_trx_room] PRIMARY KEY CLUSTERED 
(
	[UID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO

