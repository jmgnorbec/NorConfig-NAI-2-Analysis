USE [Configurateur]
GO

/****** Object:  Table [dbo].[ref_transport_skid_size]    Script Date: 2026-04-20 10:25:36 AM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [dbo].[ref_transport_skid_size](
	[uid] [int] IDENTITY(1,1) NOT NULL,
	[largeur] [int] NULL,
	[longueur] [int] NULL,
 CONSTRAINT [PK_ref_transport_skid_size] PRIMARY KEY CLUSTERED 
(
	[uid] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO

