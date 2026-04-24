USE [Configurateur]
GO

/****** Object:  Table [dbo].[uni_type_matiere]    Script Date: 2026-04-20 10:43:11 AM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [dbo].[uni_type_matiere](
	[matiere] [nvarchar](50) NOT NULL,
	[type_matiere] [nvarchar](50) NOT NULL,
	[densite] [decimal](18, 2) NULL,
	[sequence] [int] NULL
) ON [PRIMARY]
GO

