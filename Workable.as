package
{   
    public interface Workable
    {
        function needsWork():Boolean;
        
        function work(citizen:Citizen=null):void;
    }
}