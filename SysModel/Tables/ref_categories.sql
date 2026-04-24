USE [Configurateur]
GO

/****** Object:  Table [dbo].[ref_categories]    Script Date: 2026-04-20 10:22:00 AM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [dbo].[ref_categories](
	[UID] [int] IDENTITY(1,1) NOT FOR REPLICATION NOT NULL,
	[code] [nvarchar](50) NULL,
	[ref_type_UID] [int] NULL,
 CONSTRAINT [ref_categories_PK] PRIMARY KEY CLUSTERED 
(
	[UID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY],
 CONSTRAINT [ref_categories__UN] UNIQUE NONCLUSTERED 
(
	[code] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO

ALTER TABLE [dbo].[ref_categories]  WITH CHECK ADD  CONSTRAINT [ref_categories_ref_type_FK] FOREIGN KEY([ref_type_UID])
REFERENCES [dbo].[ref_type] ([UID])
GO

ALTER TABLE [dbo].[ref_categories] CHECK CONSTRAINT [ref_categories_ref_type_FK]
GO


