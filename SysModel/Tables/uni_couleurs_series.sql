USE [Configurateur]
GO

/****** Object:  Table [dbo].[uni_couleurs_series]    Script Date: 2026-04-20 10:40:22 AM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [dbo].[uni_couleurs_series](
	[uid] [int] IDENTITY(1000,1) NOT NULL,
	[serie] [nvarchar](50) NOT NULL,
	[type_peinture] [nvarchar](50) NULL,
	[ordre] [int] NULL,
	[uni_couleurs_uid] [int] NULL,
 CONSTRAINT [PK_uni_couleurs_serie] PRIMARY KEY CLUSTERED 
(
	[uid] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO

ALTER TABLE [dbo].[uni_couleurs_series] ADD  CONSTRAINT [DF_uni_couleurs_serie_serie]  DEFAULT ('') FOR [serie]
GO

