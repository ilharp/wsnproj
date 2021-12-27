import javax.swing.*;
import javax.swing.table.*;
import java.awt.*;
import java.awt.event.*;

/* Editor for table cells representing colors. Popup a color chooser. */
public class ColorCellEditor extends AbstractCellEditor
    implements TableCellEditor {
    private Color color;
    private final JButton button;

    public ColorCellEditor(String title) {
    button = new JButton();
    final JColorChooser chooser = new JColorChooser();
    final JDialog dialog = JColorChooser.createDialog
        (button, title, true, chooser,
         new ActionListener() {
         public void actionPerformed(ActionEvent e) {
             color = chooser.getColor();
         } },
         null);

    button.setBorderPainted(false);
    button.addActionListener
        (new ActionListener () {
            public void actionPerformed(ActionEvent e) {
            button.setBackground(color);
            chooser.setColor(color);
            dialog.setVisible(true);
            fireEditingStopped();
            } } );

    }

    public Object getCellEditorValue() { return color; }
    public Component getTableCellEditorComponent(JTable table,
                                                 Object value,
                                                 boolean isSelected,
                                                 int row,
                                                 int column) {
        color = (Color)value;
        return button;
    }
}
