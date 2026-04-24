USE [Configurateur]
GO

/****** Object:  Table [dbo].[sys_field_ref]    Script Date: 2026-04-20 10:32:48 AM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [dbo].[sys_field_ref](
	[UID] [int] IDENTITY(1,1) NOT FOR REPLICATION NOT NULL,
	[ForTable] [nvarchar](128) NULL,
	[ForField] [nvarchar](128) NULL,
	[LookupTable] [nvarchar](128) NULL,
	[LookupField] [int] NULL,
	[DefFromTable] [nvarchar](128) NULL,
	[DefFromField] [nvarchar](120) NULL,
	[Description] [int] NULL,
	[DefCondition?] [nvarchar](max) NULL,
	[NoDesignDoc] [nvarchar](50) NULL,
	[Comment] [nvarchar](max) NULL,
	[Help] [int] NULL,
 CONSTRAINT [sys_field_ref_PK] PRIMARY KEY CLUSTERED 
(
	[UID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO

ALTER TABLE [dbo].[sys_field_ref] ADD  CONSTRAINT [DF_sys_field_ref_LookupTable]  DEFAULT (N'ref_reference') FOR [LookupTable]
GO

ALTER TABLE [dbo].[sys_field_ref]  WITH CHECK ADD  CONSTRAINT [sys_field_ref_Localisation_FK] FOREIGN KEY([Description])
REFERENCES [dbo].[sys_localisation] ([UID])
GO

ALTER TABLE [dbo].[sys_field_ref] CHECK CONSTRAINT [sys_field_ref_Localisation_FK]
GO

