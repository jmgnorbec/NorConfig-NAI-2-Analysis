USE [Configurateur]
GO

/****** Object:  Table [dbo].[trx_piece]    Script Date: 2026-04-20 11:37:19 AM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [dbo].[trx_piece](
	[uid] [int] NOT NULL,
	[Nom] [nvarchar](50) NULL,
	[seq_id] [int] NULL,
	[trx_groupe_UID] [int] NOT NULL,
	[trx_chambre_UID] [int] NULL,
	[epi_QuoteLine] [int] NULL,
	[epi_OrderLine] [int] NULL,
	[epi_PartNum] [nvarchar](50) NULL,
	[comment] [nvarchar](max) NULL,
	[qte] [decimal](18, 4) NULL,
 CONSTRAINT [trx_piece_PK] PRIMARY KEY CLUSTERED 
(
	[uid] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO

ALTER TABLE [dbo].[trx_piece]  WITH CHECK ADD  CONSTRAINT [trx_piece_trx_chambre_FK] FOREIGN KEY([trx_chambre_UID])
REFERENCES [dbo].[trx_chambre] ([UID])
GO

ALTER TABLE [dbo].[trx_piece] CHECK CONSTRAINT [trx_piece_trx_chambre_FK]
GO

ALTER TABLE [dbo].[trx_piece]  WITH CHECK ADD  CONSTRAINT [trx_piece_trx_groupe_FK] FOREIGN KEY([trx_groupe_UID])
REFERENCES [dbo].[trx_groupe] ([UID])
GO

ALTER TABLE [dbo].[trx_piece] CHECK CONSTRAINT [trx_piece_trx_groupe_FK]
GO

