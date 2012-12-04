package com.pacytology.pcs;

import java.awt.Insets;
import java.awt.print.PageFormat;
import java.awt.print.Printable;
import java.awt.print.PrinterException;
import java.awt.print.PrinterJob;

import javax.print.PrintService;
import javax.print.PrintServiceLookup;
import javax.print.attribute.HashPrintRequestAttributeSet;
import javax.print.attribute.HashPrintServiceAttributeSet;
import javax.print.attribute.PrintRequestAttributeSet;
import javax.print.attribute.PrintServiceAttributeSet;
import javax.print.attribute.Size2DSyntax;
import javax.print.attribute.standard.MediaPrintableArea;
import javax.print.attribute.standard.MediaSize;
import javax.print.attribute.standard.OrientationRequested;
import javax.print.attribute.standard.PrinterName;

import org.apache.commons.lang.StringUtils;

public class Printer {

	static public void print(final Printable printable, final boolean portrait,
			final Insets insets, String defaultPrinterName) {
		print(printable, portrait, insets, defaultPrinterName, 
				MediaSize.NA.LETTER.getX(Size2DSyntax.MM), 
				MediaSize.NA.LETTER.getY(Size2DSyntax.MM));

	}

	/**
	 * Prints with a specified dimension.. mediaWidth & mediaHeight arguments should be specified in MM
	 * @param printable
	 * @param portrait
	 * @param insets
	 * @param defaultPrinterName
	 * @param mediaWidth in MM
	 * @param mediaHeight in MM
	 */
	static public void print(final Printable printable, final boolean portrait,
			final Insets insets, String defaultPrinterName, float mediaWidth, float mediaHeight) {
		PrinterJob pjob = PrinterJob.getPrinterJob();

		pjob.setPrintable(printable);
		// create an attribute set to store attributes from the print dialog
		// Example of setting CONDENSED Printing
		// attributes.put(TextAttribute.WIDTH, TextAttribute.WIDTH_CONDENSED);
		boolean hasDefaultPrinterName = false;
		PrintRequestAttributeSet attr = new HashPrintRequestAttributeSet();
		PrintServiceAttributeSet printServiceAttributeSet = new HashPrintServiceAttributeSet();

		if (StringUtils.isNotBlank(defaultPrinterName)) {
			PrinterName name = new PrinterName(defaultPrinterName, null);
			printServiceAttributeSet.add(name);
			hasDefaultPrinterName = true;
			PrintService[] printServices;
			PrintService printService;
			printServices = PrintServiceLookup.lookupPrintServices(null,
					printServiceAttributeSet);
			PageFormat pageFormat = new PageFormat(); // If you want to adjust
														// height and width etc.
														// of your paper.
			pageFormat = pjob.defaultPage();
			try {

				printService = printServices[0];
				pjob.setPrintService(printService); // Try setting the printer
													// you want
			} catch (ArrayIndexOutOfBoundsException e) {
				System.err.println("Error: No printer named '"
						+ defaultPrinterName + "', using default printer.");
				pageFormat = pjob.defaultPage(); // Set the default printer
													// instead.
			} catch (PrinterException exception) {
				System.err.println("Printing error: " + exception);
			}
		}

		float leftMargin = insets.left;
		float rightMargin = insets.right;
		float topMargin = insets.top;
		float bottomMargin = insets.bottom;
		if (portrait) {
			attr.add(OrientationRequested.PORTRAIT);
		} else {
			attr.add(OrientationRequested.LANDSCAPE);
			leftMargin = insets.top;
			rightMargin = insets.bottom;
			topMargin = insets.right;
			bottomMargin = insets.left;
		}



		attr.add(new MediaPrintableArea(leftMargin, topMargin, (mediaWidth
				- leftMargin - rightMargin),
				(mediaHeight - topMargin - bottomMargin), Size2DSyntax.MM));

		if (hasDefaultPrinterName || pjob.printDialog()) {
			try {
				pjob.print(attr);
			} catch (PrinterException ex) {
				ex.printStackTrace();
			}
		}

	}
}
