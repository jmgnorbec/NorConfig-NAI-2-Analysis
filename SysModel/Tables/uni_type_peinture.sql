USE [Configurateur]
GO

/****** Object:  Table [dbo].[uni_type_peinture]    Script Date: 2026-04-20 10:43:32 AM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [dbo].[uni_type_peinture](
	[type_peinture] [nvarchar](50) NOT NULL,
	[densite_pi3_metal] [decimal](18, 2) NULL,
 CONSTRAINT [PK_uni_type_peinture] PRIMARY KEY CLUSTERED 
(
	[type_peinture] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO

