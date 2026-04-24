USE [Configurateur]
GO

/****** Object:  Table [dbo].[uni_matiere]    Script Date: 2026-04-20 10:42:03 AM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [dbo].[uni_matiere](
	[matiere] [nvarchar](50) NOT NULL,
	[densite] [decimal](18, 2) NULL,
	[Sequence] [int] NULL,
 CONSTRAINT [PK_uni_matiere] PRIMARY KEY CLUSTERED 
(
	[matiere] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO

ALTER TABLE [dbo].[uni_matiere] ADD  CONSTRAINT [DF_uni_matiere_densite]  DEFAULT ((501.72)) FOR [densite]
GO

ALTER TABLE [dbo].[uni_matiere] ADD  CONSTRAINT [DF_uni_matiere_Sequence]  DEFAULT ((0)) FOR [Sequence]
GO

