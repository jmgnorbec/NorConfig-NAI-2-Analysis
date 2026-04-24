USE [Configurateur]
GO

/****** Object:  Table [dbo].[sys_condition_type]    Script Date: 2026-04-20 10:28:13 AM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [dbo].[sys_condition_type](
	[UID] [int] IDENTITY(1,1) NOT FOR REPLICATION NOT NULL,
	[descr_fr] [nvarchar](50) NULL,
	[desc_en] [nvarchar](50) NULL,
	[prog] [nvarchar](50) NULL,
	[use_cond_value_list] [bit] NULL,
 CONSTRAINT [sys_condition_type_PK] PRIMARY KEY CLUSTERED 
(
	[UID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO

