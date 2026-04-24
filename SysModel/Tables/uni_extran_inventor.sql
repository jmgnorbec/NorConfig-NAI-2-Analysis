USE [Configurateur]
GO

/****** Object:  Table [dbo].[uni_extran_inventor]    Script Date: 2026-04-20 10:40:49 AM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [dbo].[uni_extran_inventor](
	[uid] [int] IDENTITY(1,1) NOT NULL,
	[uni_mat_uid] [int] NULL,
	[inventor_name] [nvarchar](150) NULL,
	[uni_materiel_uid] [int] NULL,
 CONSTRAINT [PK_uni_extran_inventor] PRIMARY KEY CLUSTERED 
(
	[uid] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO

