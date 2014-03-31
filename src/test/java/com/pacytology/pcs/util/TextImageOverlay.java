package com.pacytology.pcs.util;
/**
 * 
 */


import java.awt.Color;
import java.awt.Font;
import java.awt.Graphics2D;
import java.awt.font.FontRenderContext;
import java.awt.geom.Rectangle2D;
import java.awt.image.BufferedImage;
import java.io.File;
import java.io.IOException;
import java.sql.CallableStatement;
import java.sql.Connection;

import javax.imageio.ImageIO;
import javax.imageio.stream.ImageOutputStream;

import org.apache.commons.io.FileUtils;

import com.pacytology.pcs.DbConnection;

public class TextImageOverlay {

	public static void main(String[] args) throws Exception
	{

		boolean newCms=true;

		String cms1500=
				newCms?"/home/oracle/reports/cms_new.png"
						:"/home/oracle/reports/cms_old.png";

		String fileName = "Image.png";
		String destImage="/home/oracle/reports/"+fileName;


		superimposeTextOnImage(
				"/u01/reports/ppr_clm",
				//"/home/oracle/reports/ppr_single.txt",
				cms1500,
				destImage,1000);

		popupChrome(destImage);

	}
	

	public static void popupChrome(String destImage) throws Exception {
		String exec = "/opt/chromium/chrome-wrapper "+destImage;
		Runtime.getRuntime().exec(exec);		
	}


	/**
	 * This assumes letter-dimensioned paper.  There are many 
	 * defaulted values (width and height of characters for Courier, etc)
	 * that can be made parameters if needed.
	 * 
	 * Also, it only works with single-page length reports.
	 */
	public static void superimposeTextOnImage(
			String textFile, 
			String sourceImage, 
			String destImage,
			int width) throws Exception {
		String text=FileUtils.readFileToString(new File(textFile));

		Font font = new Font("Courier New", Font.PLAIN, 20);
		FontRenderContext frc = new FontRenderContext(null, true, true);

		Rectangle2D bounds = font.getStringBounds(text, frc);
		int textWidth=(int) bounds.getWidth();
		int textHeight=(int) bounds.getHeight();

		//letter size dimensions
		int height=(int) (width*(11/8.5));

		BufferedImage image = new BufferedImage(width, height,   BufferedImage.TYPE_INT_RGB);

		Graphics2D g = image.createGraphics();
		g.setColor(Color.WHITE);
		g.fillRect(0, 0, width, height);

		BufferedImage cms1500Image = ImageIO.read(new File(sourceImage));
		g.drawImage(cms1500Image,0,0,width,height,null);

		g.setColor(Color.BLACK);
		g.setFont(font);

		String[]lines=text.split("\n");

		double yPos=((int) (height*.00))+14;

		int charWidth=12;
		for (String line : lines)
		{
			int xPos=(int) (width*.01);
			for (int index=0;index<line.length();index++)
			{
				String ch=line.charAt(index)+"";
				System.out.print(ch);
				if (!ch.equals(" "))
				{
					g.drawString(ch, (float) xPos, (float) yPos);
				}
				xPos+=charWidth;
			}
			System.out.println();
			yPos+=19.63;
		}

		g.dispose();

		ImageIO.write(image, "png", new File(destImage));
	}

}
